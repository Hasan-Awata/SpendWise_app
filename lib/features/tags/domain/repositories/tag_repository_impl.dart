import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:uuid/uuid.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDatasource remote;
  final TagLocalDatasource local;

  final SyncQueueRepository syncQueueRepository;
  TagRepositoryImpl({
    required this.remote,
    required this.local,

    required this.syncQueueRepository,
  });

  // =========================
  // GET LOCAL
  // =========================
  @override
  Future<Either<Failure, List<TagEntity>>> getMyTags() async {
    try {
      final networkService = Get.find<NetworkService>();
      final isOnline = networkService.isOnline.value;

      if (isOnline) {
        try {
          final remoteResponse = await remote.getMyTags();

          if (remoteResponse != null) {
            await local.clear();

            for (var remoteTag in remoteResponse) {
              remoteTag.isSynced = true;
              remoteTag.isDeleted = false;
              await local.addTagLocally(remoteTag);
            }
          }
        } catch (remoteError) {
          if (kDebugMode) {
            print("⚠️ Failed to fetch tags from remote: $remoteError");
          }
        }
      }

      final localData = await local.getMyTags();

      final entities = localData.where((e) => !e.isDeleted).map((e) {
        return e.toEntity();
      }).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure("حدث خطأ أثناء جلب التصنيفات: ${e.toString()}"));
    }
  }

  // =========================
  // ADD LOCAL ONLY
  // =========================
  @override
  Future<Either<Failure, String>> addTag(TagEntity tag) async {
    try {
      final model = TagModel.fromEntity(tag)
        ..isSynced = false
        ..isDeleted = false
        ..id = null;

      await local.addTagLocally(model);
      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: model.localId,
          action: SyncAction.create,
          table: "tag",
          createdAt: DateTime.now(),
          isarId: model.isarId,
        ),
      );

      return const Right("تم الحفظ محلياً");
    } catch (_) {
      return Left(CacheFailure("فشل الحفظ"));
    }
  }

  // =========================
  // UPDATE LOCAL ONLY
  // =========================
  @override
  Future<Either<Failure, String>> updateTag(TagEntity tag) async {
    try {
      final localtag = await local.getTag(tag.localId);

      if (localtag == null) {
        return const Right("غير موجود");
      }

      localtag
        ..name = tag.name
        ..isSynced = false;

      await local.updateTagLocally(localtag);
      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: localtag.localId,
          action: SyncAction.update,
          table: "tag",
          createdAt: DateTime.now(),
          isarId: localtag.isarId,
        ),
      );

      return const Right("تم التحديث محلياً");
    } catch (_) {
      return Left(CacheFailure("فشل التحديث"));
    }
  }

  // =========================
  // DELETE LOCAL ONLY
  // =========================
  @override
  Future<Either<Failure, String>> deleteTag(TagEntity tag) async {
    try {
      final localTag = await local.getTag(tag.localId);

      if (localTag == null) {
        return const Right("غير موجود");
      }

      localTag
        ..isDeleted = true
        ..isSynced = false;

      await local.updateTagLocally(localTag);
      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: localTag.localId,
          action: SyncAction.delete,
          table: "tag",
          createdAt: DateTime.now(),
          isarId: localTag.isarId,
        ),
      );

      return const Right("تم الحذف محلياً");
    } catch (_) {
      return Left(CacheFailure("فشل الحذف"));
    }
  }
}
