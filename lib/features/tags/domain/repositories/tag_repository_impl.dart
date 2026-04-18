import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  final TagLocalDatasource tagLocalDatasource;
  final TagRemoteDatasource tagRemoteDatasource;

  TagRepositoryImpl({
    required this.tagLocalDatasource,
    required this.tagRemoteDatasource,
  });

  @override
  Future<Either<Failure, Unit>> addTag(TagEntity tagEntity) async {
    final tag = tagEntity as TagModel;
    try {
      print("🚀 Starting addTag: ${tag.localId}");
      tag.isSynced = false;
      await tagLocalDatasource.addTagLocally(tag);

      _safeRemoteCall(() async {
        final remoteTag = await tagRemoteDatasource.addTag(tag);
        if (remoteTag != null) {
          print("✅ Server Add Success: ${remoteTag.id}");
          remoteTag.isSynced = true;
          remoteTag.localId = tag.localId;
          await tagLocalDatasource.updateTagLocally(remoteTag);
        }
      });

      return const Right(unit);
    } catch (e) {
      print("❌ Local Add Error: $e");
      return Left(CacheFailure("فشل الحفظ في التخزين المحلي"));
    }
  }

  @override
  Future<Either<Failure, PagedResponse<TagModel>>> getMyTags(
    PageRequest page,
  ) async {
    try {
      print("📡 Fetching Tags from Server - Page: ${page.pageNumber}");
      final remoteResponse = await tagRemoteDatasource.getMyTags(page);

      for (var model in remoteResponse.data) {
        model.isSynced = true;
        await tagLocalDatasource.addTagLocally(model);
      }
      return Right(remoteResponse);
    } catch (e) {
      print("🌐 Connection Issue: Switching to Local Storage. Error: $e");
      _safeRemoteCall(() => syncPendingTags());
      return await _getLocalPagedResponse(page);
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTag(TagModel tag) async {
    try {
      print("🔄 Updating Tag Locally: ${tag.id}");
      tag.isSynced = false;
      await tagLocalDatasource.updateTagLocally(tag);

      _safeRemoteCall(() async {
        await tagRemoteDatasource.updateTag(tag);
        print("✅ Server Update Done");
        tag.isSynced = true;
        await tagLocalDatasource.updateTagLocally(tag);
      });
      return const Right(unit);
    } catch (e) {
      print("❌ Local Update Error: $e");
      return Left(CacheFailure("فشل تحديث البيانات محلياً"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTag(TagModel tag) async {
    try {
      print("🗑️ Marking Tag for Removal: ${tag.id}");
      tag.localId = "REMOVE";
      tag.isSynced = false;
      await tagLocalDatasource.updateTagLocally(tag);

      _safeRemoteCall(() async {
        if (tag.id != null && tag.id != -1) {
          await tagRemoteDatasource.deleteTag(tag);
          print("✅ Server Delete Done");
        }
        await tagLocalDatasource.deleteTagLocally(tag);
      });
      return const Right(unit);
    } catch (e) {
      print("❌ Local Delete Error: $e");
      return Left(CacheFailure("فشل عملية الحذف محلياً"));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingTags() async {
    try {
      final allLocal = await tagLocalDatasource.getMyTags();
      final pending = allLocal
          .where((t) => !t.isSynced || t.localId == "REMOVE")
          .toList();

      print("🔄 Sync Engine: Found ${pending.length} pending tags");

      for (var tag in pending) {
        try {
          if (tag.localId == "REMOVE") {
            if ((tag.id != null && tag.id != -1) || tag.localId == "REMOVE") {
              await tagRemoteDatasource.deleteTag(tag);
            }
            await tagLocalDatasource.deleteTagLocally(tag);
            print("📤 Synced: DELETED Tag ${tag.id}");
            continue;
          }

          if (tag.id == null || tag.id == -1) {
            final remote = await tagRemoteDatasource.addTag(tag);
            if (remote != null) {
              remote.isSynced = true;
              remote.localId = tag.localId;
              await tagLocalDatasource.updateTagLocally(remote);
              print("📤 Synced: CREATED Tag ${remote.id}");
            }
          } else {
            await tagRemoteDatasource.updateTag(tag);
            tag.isSynced = true;
            await tagLocalDatasource.updateTagLocally(tag);
            print("📤 Synced: UPDATED Tag ${tag.id}");
          }
        } catch (e) {
          print("⚠️ Sync Error for Tag: $e");
          continue;
        }
      }
      return const Right(unit);
    } catch (e) {
      print("❌ Global Tag Sync Failure: $e");
      return Left(ServerFailure("خطأ غير متوقع أثناء المزامنة"));
    }
  }

  Future<Either<Failure, PagedResponse<TagModel>>> _getLocalPagedResponse(
    PageRequest page,
  ) async {
    try {
      final all = await tagLocalDatasource.getMyTags();
      final filtered = all
          .where((t) => t.localId != "REMOVE")
          .toList()
          .reversed
          .toList();

      final start = (page.pageNumber - 1) * page.pageSize;
      final totalPages = (filtered.length / page.pageSize).ceil();

      if (start >= filtered.length) {
        return Right(
          PagedResponse(
            data: [],
            totalRecords: filtered.length,
            pageNumber: page.pageNumber,
            pageSize: page.pageSize,
            totalPages: totalPages,
          ),
        );
      }

      final end = start + page.pageSize;
      final sliced = filtered.sublist(
        start,
        end > filtered.length ? filtered.length : end,
      );

      print("📦 Local Tags Loaded: ${sliced.length} items");
      return Right(
        PagedResponse(
          data: sliced,
          totalRecords: filtered.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في قراءة البيانات المحلية"));
    }
  }

  Future<void> _safeRemoteCall(Future<dynamic> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint("📢 Tag Background Sync Info: $e");
    }
  }
}
