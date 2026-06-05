import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/debts/data/datasources/shared_debt_local_datasource.dart';
import 'package:spendwise/features/debts/data/datasources/shared_debt_remote_datasource.dart';
import 'package:spendwise/features/debts/data/models/shared_debt_model.dart';
import 'package:spendwise/features/debts/data/repositories/shared_debt_repository.dart';
import 'package:spendwise/features/debts/domain/entities/shared_debt_entity.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:uuid/uuid.dart';

class SharedDebtRepositoryImpl implements SharedDebtRepository {
  final SharedDebtLocalDataSource localDataSource;
  final SharedDebtRemoteDatasource remote;
  final SyncQueueRepository syncQueueRepository;

  SharedDebtRepositoryImpl({
    required this.localDataSource,
    required this.remote,
    required this.syncQueueRepository,
  });

  // =========================================================
  // GET
  // =========================================================

  @override
  Future<Either<Failure, List<SharedDebtEntity>>> getDebts(int? userId) async {
    try {
      final network = Get.find<NetworkService>();

      if (network.isOnline.value) {
        try {
          final remoteResponse = await remote.getMyDebts(userId!);

          await localDataSource.clear();

          for (final debt in remoteResponse) {
            debt.isSynced = true;
            debt.isDeleted = false;

            await localDataSource.addDebt(debt);
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Remote failed, fallback to local: $e");
          }
        }
      }

      final localData = await localDataSource.getDebts();

      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final slice = filtered;

      return Right(slice.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure("Error loading debts: $e"));
    }
  }

  // =========================================================
  // CREATE
  // =========================================================

  @override
  Future<Either<Failure, String>> addDebt(SharedDebtEntity debt) async {
    try {
      final network = Get.find<NetworkService>();

      final model = SharedDebtModel.fromEntity(debt)
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDeleted = false
        ..isSynced = false;

      await localDataSource.addDebt(model);

      if (network.isOnline.value) {
        try {
          final remoteDebt = await remote.addDebt(model);

          model
            ..debtId = remoteDebt.debtId
            ..isSynced = true;

          await localDataSource.updateDebt(model);
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Online create failed → queue fallback: $e");
          }

          await _addToQueue(model, SyncAction.create);
        }
      } else {
        await _addToQueue(model, SyncAction.create);
      }

      return const Right("Debt saved");
    } catch (e) {
      return Left(CacheFailure("Add debt failed: $e"));
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================

  @override
  Future<Either<Failure, Unit>> updateDebt(SharedDebtEntity entity) async {
    try {
      final local = await localDataSource.getDebt(entity.localId);

      if (local == null) {
        return Left(CacheFailure("Not found"));
      }

      local
        ..amount = entity.amount
        ..title = entity.title
        ..status = entity.status
        ..dueDate = entity.dueDate
        ..paidAmount = entity.paidAmount
        ..creditorWalletId = entity.creditorWalletId
        ..debtorWalletId = entity.debtorWalletId
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDataSource.updateDebt(local);

      final network = Get.find<NetworkService>();

      if (network.isOnline.value) {
        try {
          await remote.updateDebt(local);

          local.isSynced = true;

          await localDataSource.updateDebt(local);
        } catch (e) {
          await _addToQueue(local, SyncAction.update);
        }
      } else {
        await _addToQueue(local, SyncAction.update);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("Update failed: $e"));
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  @override
  Future<Either<Failure, Unit>> deleteDebt(SharedDebtEntity entity) async {
    try {
      final local = await localDataSource.getDebt(entity.localId);

      if (local == null) {
        return Left(CacheFailure("Not found"));
      }

      local
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await localDataSource.updateDebt(local);

      final network = Get.find<NetworkService>();

      if (network.isOnline.value) {
        try {
          final result = await remote.deleteDebt(local);

          if (result) {
            await localDataSource.deleteDebt(local);
          } else {
            return Left(ServerFailure("فشل حذف الدين من السيرفر"));
          }
        } catch (e) {
          await _addToQueue(local, SyncAction.delete);
        }
      } else {
        await _addToQueue(local, SyncAction.delete);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("Delete failed: $e"));
    }
  }

  // =========================================================
  // QUEUE
  // =========================================================

  Future<void> _addToQueue(SharedDebtModel model, SyncAction action) async {
    await syncQueueRepository.addToQueue(
      SyncQueueModel(
        id: const Uuid().v4(),
        localId: model.localId,
        isarId: model.isarId,
        table: "shared_debt",
        action: action,
        createdAt: DateTime.now(),
      ),
    );
  }

  // =========================================================
  // PAGINATION
  // =========================================================

  List<SharedDebtModel> _paginate(
    List<SharedDebtModel> list,
    PageRequest page,
  ) {
    final start = (page.pageNumber - 1) * page.pageSize;

    final end = (start + page.pageSize).clamp(0, list.length);

    return start >= list.length ? [] : list.sublist(start, end);
  }
}
