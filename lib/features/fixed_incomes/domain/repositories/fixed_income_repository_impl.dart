import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_local_datasource.dart';
import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_remote_datasource.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/fixed_incomes/data/repositories/fixed_income_repository.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:uuid/uuid.dart';

class FixedIncomeRepositoryImpl implements FixedIncomeRepository {
  final FixedIncomeLocalDataSource localDataSource;
  final FixedIncomeRemoteDataSource remote;
  final SyncQueueRepository syncQueueRepository;
  final WalletRepository walletRepo;

  FixedIncomeRepositoryImpl({
    required this.localDataSource,
    required this.remote,
    required this.syncQueueRepository,
    required this.walletRepo,
  });

  @override
  Future<Either<Failure, String>> addFixedIncome(FixedIncomeModel model) async {
    try {
      model.isSynced = false;
      model.isDeleted = false;

      final network = Get.find<NetworkService>();

      if (!network.isOnline.value) {
        await localDataSource.saveFixedIncome(model);
        await _addToQueue(model, SyncAction.create);
        return const Right('FixedIncome saved offline');
      }

      final remoteResponse = await remote.addFixedIncome(model);
      if (remoteResponse == null) return Left(ServerFailure('Server error'));

      model.markSynced(remoteResponse.fixedIncomeId);
      await localDataSource.saveFixedIncome(model);

      return const Right('FixedIncome saved');
    } catch (e) {
      return Left(ServerFailure('Add failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateFixedIncome(
    FixedIncomeModel model,
  ) async {
    try {
      final local = await localDataSource.getFixedIncomeByIsarId(model.isarId);
      if (local == null) return Left(CacheFailure('Not found'));

      local
        ..title = model.title
        ..amount = model.amount
        ..isMonthly = model.isMonthly
        ..isActive = model.isActive
        ..days = model.days
        ..lastTime = model.lastTime
        ..isSynced = false;

      await localDataSource.saveFixedIncome(local);

      if (Get.find<NetworkService>().isOnline.value) {
        try {
          await remote.updateFixedIncome(local);
          local.isSynced = true;
          await localDataSource.saveFixedIncome(local);
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
  Future<Either<Failure, Unit>> deleteFixedIncome(
    FixedIncomeModel model,
  ) async {
    try {
      final local = await localDataSource.getFixedIncomeByIsarId(model.isarId);
      if (local == null) return Left(CacheFailure('Not found'));

      local
        ..isDeleted = true
        ..isSynced = false;

      await localDataSource.saveFixedIncome(local);

      if (Get.find<NetworkService>().isOnline.value) {
        try {
          final res = await remote.deleteFixedIncome(local.fixedIncomeId);
          if (res) {
            await localDataSource.deleteFixedIncome(local.isarId);
          } else {
            return Left(ServerFailure("فشل الحذف"));
          }
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
  Future<Either<Failure, List<FixedIncomeModel>>> getFixedIncomes() async {
    try {
      final network = Get.find<NetworkService>();
      final isOnline = network.isOnline.value;

      if (isOnline) {
        try {
          final remoteResponse = await remote.getFixedIncomes();

          if (remoteResponse != null) {
            await localDataSource.clear();

            for (final income in remoteResponse) {
              income.isSynced = true;
              income.isDeleted = false;
              await localDataSource.saveFixedIncome(income);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Remote failed, fallback to local: $e");
          }
        }
      }

      final localData = await localDataSource.getFixedIncomes();

      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.lastTime.compareTo(a.lastTime));

      final slice = filtered;

      return Right(slice);
    } catch (e) {
      return Left(CacheFailure("Error loading incomes: $e"));
    }
  }

  // دالة مساعدة لعملية المزامنة
  Future<void> _addToQueue(FixedIncomeModel model, SyncAction action) async {
    await syncQueueRepository.addToQueue(
      SyncQueueModel(
        id: const Uuid().v4(),
        isarId: model.isarId,
        table: 'fixed_income',
        action: action,
        createdAt: DateTime.now(),
        localId: '${model.isarId}',
      ),
    );
  }
}
