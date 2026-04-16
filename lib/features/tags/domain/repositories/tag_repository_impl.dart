import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';

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
      tag.isSynced = false;
      final savedLocalTag = await tagLocalDatasource.addTagLocally(tag);

      _safeRemoteCall(() async {
        final remoteTag = await tagRemoteDatasource.addTag(savedLocalTag!);
        remoteTag.isSynced = true;
        remoteTag.localId = savedLocalTag.localId;
        await tagLocalDatasource.updateTagLocally(remoteTag);
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل الحفظ في التخزين المحلي"));
    }
  }

  @override
  Future<Either<Failure, PagedResponse<TagModel>>> getMyTags(
    PageRequest page,
  ) async {
    try {
      final remoteResponse = await tagRemoteDatasource.getMyTags(page);

      for (var model in remoteResponse.data) {
        model.isSynced = true;
        await tagLocalDatasource.addTagLocally(model);
      }
      return Right(remoteResponse);
    } catch (e) {
      return await _getLocalPagedResponse(page);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTag(TagModel tag) async {
    try {
      _safeRemoteCall(() async {
        if (tag.id != null && tag.id != -1) {
          await tagRemoteDatasource.deleteTag(tag);
        }
        await tagLocalDatasource.deleteTagLocally(tag);
      });

      if (tag.id == null || tag.id == -1) {
        await tagLocalDatasource.deleteTagLocally(tag);
      } else {
        tag.isSynced = false;
        await tagLocalDatasource.updateTagLocally(tag);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل تنفيذ طلب الحذف محلياً"));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTag(TagModel tag) async {
    try {
      tag.isSynced = false;
      await tagLocalDatasource.updateTagLocally(tag);

      _safeRemoteCall(() async {
        await tagRemoteDatasource.updateTag(tag);
        tag.isSynced = true;
        await tagLocalDatasource.updateTagLocally(tag);
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل تحديث البيانات محلياً"));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingTags() async {
    try {
      final allLocal = await tagLocalDatasource.getMyTags();

      for (var tag in allLocal) {
        try {
          if (!tag.isSynced) {
            if (tag.id == null || tag.id == -1) {
              final remote = await tagRemoteDatasource.addTag(tag);
              remote.isSynced = true;
              remote.localId = tag.localId;
              await tagLocalDatasource.updateTagLocally(remote);
            } else {
              await tagRemoteDatasource.updateTag(tag);
              tag.isSynced = true;
              await tagLocalDatasource.updateTagLocally(tag);
            }
          }
        } catch (_) {
          continue;
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure("خطأ غير متوقع أثناء المزامنة"));
    }
  }

  Future<void> _safeRemoteCall(Future<dynamic> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint("Tag Silent Sync Error: $e");
    }
  }

  Future<Either<Failure, PagedResponse<TagModel>>> _getLocalPagedResponse(
    PageRequest page,
  ) async {
    try {
      final all = await tagLocalDatasource.getMyTags();
      final start = (page.pageNumber - 1) * page.pageSize;
      final totalPages = (all.length / page.pageSize).ceil();

      if (start >= all.length) {
        return Right(
          PagedResponse(
            data: [],
            totalRecords: all.length,
            pageNumber: page.pageNumber,
            pageSize: page.pageSize,
            totalPages: totalPages,
          ),
        );
      }

      final end = start + page.pageSize;
      final sliced = all.sublist(start, end > all.length ? all.length : end);

      return Right(
        PagedResponse<TagModel>(
          data: sliced,
          totalRecords: all.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في قراءة البيانات المحلية"));
    }
  }
}
