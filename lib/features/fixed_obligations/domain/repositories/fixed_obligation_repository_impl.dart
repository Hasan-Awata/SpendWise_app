// lib/features/fixed_obligations/data/repositories/fixed_obligation_repository_impl.dart
// FixedObligationRepositoryImpl: طبقة المستودع لإدارة الالتزامات المالية، تضمن تناسق البيانات بين التخزين المحلي (Isar) والسيرفر مع دعم المزامنة (Offline-first).

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/fixed_obligations/data/datasources/fixed_obligation_local_datasource.dart';
import 'package:spendwise/features/fixed_obligations/data/datasources/fixed_obligation_remote_datasource.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';
import 'package:spendwise/features/fixed_obligations/data/repositories/fixed_obligation_repository.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:uuid/uuid.dart';

class FixedObligationRepositoryImpl implements FixedObligationRepository {
  final FixedObligationLocalDataSource localDataSource;
  final FixedObligationRemoteDataSource remote;
  final SyncQueueRepository syncQueueRepository;

  FixedObligationRepositoryImpl({
    required this.localDataSource,
    required this.remote,
    required this.syncQueueRepository,
  });

  @override
  Future<Either<Failure, String>> addFixedObligation(
    FixedObligationModel model,
  ) async {
    try {
      model.isSynced = false;
      model.isDeleted = false;

      final network = Get.find<NetworkService>();

      if (!network.isOnline.value) {
        await localDataSource.saveFixedObligation(model);
        await _addToQueue(model, SyncAction.create);
        return const Right('FixedObligation saved offline');
      }

      final remoteResponse = await remote.addFixedObligation(model);
      if (remoteResponse == null) return Left(ServerFailure('Server error'));

      model.markSynced(remoteResponse.id);
      await localDataSource.saveFixedObligation(model);

      return const Right('FixedObligation saved');
    } catch (e) {
      return Left(ServerFailure('Add failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateFixedObligation(
    FixedObligationModel model,
  ) async {
    try {
      final local = await localDataSource.getFixedObligationByIsarId(
        model.isarId,
      );
      if (local == null) return Left(CacheFailure('Not found'));

      local
        ..title = model.title
        ..amount = model.amount
        ..dueDate = model.dueDate
        ..isActive = model.isActive
        ..isSynced = false;

      await localDataSource.saveFixedObligation(local);

      if (Get.find<NetworkService>().isOnline.value) {
        try {
          await remote.updateFixedObligation(local);
          local.isSynced = true;
          await localDataSource.saveFixedObligation(local);
        } catch (_) {
          await _addToQueue(local, SyncAction.update);
        }
      } else {
        await _addToQueue(local, SyncAction.update);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Update failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteFixedObligation(
    FixedObligationModel model,
  ) async {
    try {
      final local = await localDataSource.getFixedObligationByIsarId(
        model.isarId,
      );
      if (local == null) return Left(CacheFailure('Not found'));

      local
        ..isDeleted = true
        ..isSynced = false;

      await localDataSource.saveFixedObligation(local);

      if (Get.find<NetworkService>().isOnline.value) {
        try {
          await remote.deleteFixedObligation(local.id);
          await localDataSource.deleteFixedObligation(local.isarId);
        } catch (_) {
          await _addToQueue(local, SyncAction.delete);
        }
      } else {
        await _addToQueue(local, SyncAction.delete);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Delete failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FixedObligationModel>>>
  getFixedObligations() async {
    try {
      if (Get.find<NetworkService>().isOnline.value) {
        try {
          final remoteData = await remote.getFixedObligations();
          if (remoteData != null) {
            // ملاحظة: يمكنك هنا تحديث الـ Local DB بذكاء بدلاً من المسح الكامل
            for (final item in remoteData) {
              item.isSynced = true;
              await localDataSource.saveFixedObligation(item);
            }
          }
        } catch (e) {
          debugPrint("Remote sync failed, using local: $e");
        }
      }

      final localData = await localDataSource.getFixedObligations();
      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure("Error: $e"));
    }
  }

  Future<void> _addToQueue(
    FixedObligationModel model,
    SyncAction action,
  ) async {
    await syncQueueRepository.addToQueue(
      SyncQueueModel(
        id: const Uuid().v4(),
        isarId: model.isarId,
        table: 'FixedObligation',
        action: action,
        createdAt: DateTime.now(),
        localId: '${model.isarId}',
      ),
    );
  }
}
