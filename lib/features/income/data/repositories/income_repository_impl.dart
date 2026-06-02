import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:uuid/uuid.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeLocalDataSource localDataSource;
  final IncomeRemoteDatasource remote;
  final SyncQueueRepository syncQueueRepository;

  IncomeRepositoryImpl({
    required this.localDataSource,
    required this.remote,
    required this.syncQueueRepository,
  });

  // =========================================================
  // GET (Remote if online + cache fallback)
  // =========================================================
  @override
  Future<Either<Failure, PagedResponse<IncomeEntity>>> getIncomes(
    int? userId,
    PageRequest page,
  ) async {
    try {
      final network = Get.find<NetworkService>();
      final isOnline = network.isOnline.value;

      if (isOnline) {
        try {
          final remoteResponse = await remote.getMyIncomes(userId!, page);

          if (remoteResponse != null) {
            await localDataSource.clear();

            for (final income in remoteResponse.data) {
              income.isSynced = true;
              income.isDeleted = false;
              await localDataSource.addIncome(income);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Remote failed, fallback to local: $e");
          }
        }
      }

      final localData = await localDataSource.getIncomes();

      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final slice = _paginate(filtered, page);

      return Right(
        PagedResponse(
          data: slice.map((e) => e.toEntity()).toList(),
          totalRecords: filtered.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: (filtered.length / page.pageSize).ceil(),
        ),
      );
    } catch (e) {
      return Left(CacheFailure("Error loading incomes: $e"));
    }
  }

  // =========================================================
  // CREATE
  // =========================================================
  @override
  Future<Either<Failure, String>> addIncome(IncomeEntity income) async {
    try {
      final network = Get.find<NetworkService>();
      final isOnline = network.isOnline.value;

      final model = IncomeModel.fromEntity(income)
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDeleted = false
        ..isSynced = false;

      // 1. Always save locally first
      await localDataSource.addIncome(model);

      if (isOnline) {
        try {
          final remoteIncome = await remote.addIncome(model);

          if (remoteIncome != null) {
            model
              ..id = remoteIncome.id
              ..isSynced = true;

            await localDataSource.updateIncome(model);
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Online create failed → queue fallback: $e");
          }

          await _addToQueue(model, SyncAction.create);
        }
      } else {
        await _addToQueue(model, SyncAction.create);
      }

      return const Right("Income saved");
    } catch (e) {
      return Left(CacheFailure("Add income failed: $e"));
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================
  @override
  Future<Either<Failure, Unit>> updateIncome(IncomeEntity entity) async {
    try {
      final local = await localDataSource.getIncome(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      local
        ..amount = entity.amount
        ..title = entity.title
        ..date = entity.date
        ..walletId = entity.walletId
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDataSource.updateIncome(local);

      final network = Get.find<NetworkService>();

      if (network.isOnline.value) {
        try {
          await remote.updateIncome(local);
          local.isSynced = true;
          await localDataSource.updateIncome(local);
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
  Future<Either<Failure, Unit>> deleteIncome(IncomeEntity entity) async {
    try {
      final local = await localDataSource.getIncome(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      local
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await localDataSource.updateIncome(local);

      final network = Get.find<NetworkService>();

      if (network.isOnline.value) {
        try {
          await remote.deleteIncome(local);
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
  // QUEUE HELPER
  // =========================================================
  Future<void> _addToQueue(IncomeModel model, SyncAction action) async {
    await syncQueueRepository.addToQueue(
      SyncQueueModel(
        id: const Uuid().v4(),
        localId: model.localId,
        isarId: model.isarId,
        table: "income",
        action: action,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<IncomeModel> _paginate(List<IncomeModel> list, PageRequest page) {
    final start = (page.pageNumber - 1) * page.pageSize;
    final end = (start + page.pageSize).clamp(0, list.length);
    return start >= list.length ? [] : list.sublist(start, end);
  }
}
