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
  // GET (no change except safe sync)
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
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Remote fetch failed: $e");
          }
        }
      }

      final localData = await local.getMyTags();

      return Right(
        localData.where((e) => !e.isDeleted).map((e) => e.toEntity()).toList(),
      );
    } catch (e) {
      return Left(CacheFailure("حدث خطأ: ${e.toString()}"));
    }
  }

  // =========================
  // ADD (Instant Sync)
  // =========================
  @override
  Future<Either<Failure, String>> addTag(TagEntity tag) async {
    try {
      final networkService = Get.find<NetworkService>();
      final isOnline = networkService.isOnline.value;

      final model = TagModel.fromEntity(tag)
        ..isSynced = false
        ..isDeleted = false
        ..id = null;

      await local.addTagLocally(model);

      if (isOnline) {
        try {
          final remoteTag = await remote.addTag(model);

          if (remoteTag != null) {
            model
              ..id = remoteTag.id
              ..isSynced = true;

            await local.updateTagLocally(model);
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Online add failed, fallback to queue: $e");
          }

          await _addToQueue(model);
        }
      } else {
        await _addToQueue(model);
      }

      return const Right("تم الحفظ");
    } catch (_) {
      return Left(CacheFailure("فشل الحفظ"));
    }
  }

  // =========================
  // UPDATE (Instant Sync)
  // =========================
  @override
  Future<Either<Failure, String>> updateTag(TagEntity tag) async {
    try {
      final networkService = Get.find<NetworkService>();
      final isOnline = networkService.isOnline.value;

      final localtag = await local.getTag(tag.localId);

      if (localtag == null) {
        return const Right("غير موجود");
      }

      localtag
        ..name = tag.name
        ..isSynced = false;

      await local.updateTagLocally(localtag);

      if (isOnline) {
        try {
          await remote.updateTag(localtag);

          localtag.isSynced = true;
          await local.updateTagLocally(localtag);
        } catch (e) {
          await _addToQueue(localtag);
        }
      } else {
        await _addToQueue(localtag);
      }

      return const Right("تم التحديث");
    } catch (_) {
      return Left(CacheFailure("فشل التحديث"));
    }
  }

  // =========================
  // DELETE (Instant Sync)
  // =========================
  @override
  Future<Either<Failure, String>> deleteTag(TagEntity tag) async {
    try {
      final networkService = Get.find<NetworkService>();
      final isOnline = networkService.isOnline.value;

      final localTag = await local.getTag(tag.localId);

      if (localTag == null) {
        return const Right("غير موجود");
      }

      localTag
        ..isDeleted = true
        ..isSynced = false;

      await local.updateTagLocally(localTag);

      if (isOnline) {
        try {
          await remote.deleteTag(localTag.id!);
          await local.deleteTagLocally(localTag);
        } catch (e) {
          await _addToQueue(localTag);
        }
      } else {
        await _addToQueue(localTag);
      }

      return const Right("تم الحذف");
    } catch (_) {
      return Left(CacheFailure("فشل الحذف"));
    }
  }

  // =========================
  // QUEUE HELPER
  // =========================
  Future<void> _addToQueue(TagModel model) async {
    await syncQueueRepository.addToQueue(
      SyncQueueModel(
        id: const Uuid().v4(),
        localId: model.localId,
        action: SyncAction
            .create, // ملاحظة: لازم تفرّق update/delete إذا بدك دقة أعلى
        table: "tag",
        createdAt: DateTime.now(),
        isarId: model.isarId,
      ),
    );
  }
}
