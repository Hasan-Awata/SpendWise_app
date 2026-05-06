import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  final TagLocalDatasource tagLocalDatasource;
  final TagRemoteDatasource tagRemoteDatasource;

  TagRepositoryImpl({
    required this.tagLocalDatasource,
    required this.tagRemoteDatasource,
  });

  // ========================= ADD =========================
  @override
  Future<Either<Failure, String>> addTag(TagModel tag) async {
    final network = NetworkService();
    return await network.saveLocalAndSync<String>(
      localSave: () async {
        await tagLocalDatasource.addTagLocally(tag);
      },
      remoteSave: () async {
        tag.isSynced = false;

        final result = await tagRemoteDatasource.addTag(tag);
        if (result == null) {
          throw Exception("Remote addTag returned null");
        }

        return "تم الحفظ بنجاح";
      },
      onSyncSuccess: (_) async {
        tag.isSynced = true;
        await tagLocalDatasource.updateTagLocally(tag);
      },
      localResult: "تم حفظ الوسم محلياً",
    );
  }

  // ========================= GET =========================
  @override
  Future<Either<Failure, PagedResponse<TagModel>>> getMyTags(
    PageRequest page,
  ) async {
    try {
      print("📡 Fetching Tags from Server - Page: ${page.pageNumber}");

      final remoteResponse = await tagRemoteDatasource.getMyTags(page);

      // ✅ تحسين الأداء (بدل await داخل loop)
      await Future.wait(
        remoteResponse.data.map((model) async {
          model.isSynced = true;
          await tagLocalDatasource.addTagLocally(model);
        }),
      );

      return Right(remoteResponse);
    } catch (e) {
      print("🌐 Connection Issue: Switching to Local Storage. Error: $e");

      return await _getLocalPagedResponse(page);
    }
  }

  // ========================= UPDATE =========================
  @override
  Future<Either<Failure, Unit>> updateTag(TagModel tag) async {
    try {
      print("🔄 Updating Tag Locally: ${tag.id}");

      tag.isSynced = false;

      // ✅ Local First
      await tagLocalDatasource.updateTagLocally(tag);

      // 🔥 Background Sync
      _safeRemoteCall(() async {
        final remote = await tagRemoteDatasource.updateTag(tag);

        if (remote != null) {
          remote.isSynced = true;
          await tagLocalDatasource.updateTagLocally(remote);
        }

        print("✅ Server Update Done");
      });

      return const Right(unit);
    } catch (e) {
      print("❌ Local Update Error: $e");
      return Left(CacheFailure("فشل تحديث البيانات محلياً"));
    }
  }

  // ========================= DELETE =========================
  @override
  Future<Either<Failure, String>> deleteTag(TagModel tag) async {
    try {
      // ✅ Soft Delete
      tag.localId = "REMOVE";
      tag.isSynced = false;

      await tagLocalDatasource.updateTagLocally(tag);

      // 🔥 Background Sync
      _safeRemoteCall(() async {
        try {
          if (tag.id != null && tag.id != -1) {
            await tagRemoteDatasource.deleteTag(tag.id!);
          }

          await tagLocalDatasource.deleteTagLocally(tag);

          print("📤 Synced: DELETED Tag ${tag.id}");
        } catch (e) {
          print("⚠️ Remote Delete Failed: $e");
        }
      });

      return const Right("تم الحذف");
    } catch (localError) {
      print("❌ Local Delete Critical Error: $localError");
      return Left(CacheFailure("فشل عملية الحذف محلياً"));
    }
  }

  // ========================= SYNC ENGINE =========================
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
            if (tag.id != null && tag.id != -1) {
              await tagRemoteDatasource.deleteTag(tag.id!);
            }

            await tagLocalDatasource.deleteTagLocally(tag);

            print("📤 Synced: DELETED Tag ${tag.id}");
            continue;
          }

          if (tag.id != null && tag.id != -1) {
            final remote = await tagRemoteDatasource.updateTag(tag);

            if (remote != null) {
              remote.isSynced = true;
              await tagLocalDatasource.updateTagLocally(remote);

              print("📤 Synced: UPDATED ${tag.id}");
            }
          } else {
            final remote = await tagRemoteDatasource.addTag(tag);

            if (remote != null) {
              remote.isSynced = true;

              await tagLocalDatasource.updateTagLocally(remote);

              print("📤 Synced: CREATED Tag ${remote.id}");
            }
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

  // ========================= LOCAL FALLBACK =========================
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

  // ========================= SAFE REMOTE =========================
  Future<void> _safeRemoteCall(Future<dynamic> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint("📢 Tag Background Sync Info: $e");
    }
  }
}
