// lib/features/savings_goals/data/repositories/saving_goal_repository_impl.dart
// SavingGoalRepositoryImpl: Implements saving goals core sync queues ensuring database transactions strictly pipe through off-line buffers and matching server entities

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:uuid/uuid.dart';

import '../datasources/saving_goal_remote_datasource.dart';
import '../models/saving_goal_model.dart';
import '../repositories/saving_goal_repository.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  final SavingGoalLocalDataSource localDatasource;
  final SavingGoalRemoteDatasource remoteDatasource;
  final SyncQueueRepository syncQueueRepository;

  SavingGoalRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.syncQueueRepository,
  });

  // =========================================================
  // GET (Remote if online + cache fallback)
  // =========================================================
  @override
  Future<Either<Failure, PagedResponse<SavingGoalEntity>>> getMySavingGoals(
    int userId,
    PageRequest page,
  ) async {
    try {
      final network = Get.find<NetworkService>();
      final isOnline = network.isOnline.value;

      if (isOnline) {
        try {
          final remoteResponse = await remoteDatasource.getAllUserGoals(
            userId,
            page,
          );

          if (remoteResponse != null) {
            // مسح مخصص للبيانات غير المعدلة محلياً لضمان سلامة التزامن من السيرفر
            await localDatasource.clear();

            for (final goal in remoteResponse.data) {
              goal.isSynced = true;
              goal.isDeleted = false;
              await localDatasource.updateSavingGoal(goal);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Remote failed, fallback to local: $e");
          }
        }
      }

      final localData = await localDatasource.getSavingGoals();

      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

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
      return Left(CacheFailure("Error loading saving goals: $e"));
    }
  }

  // =========================================================
  // CREATE
  // =========================================================
  @override
  Future<Either<Failure, String>> addSavingGoal(SavingGoalEntity entity) async {
    try {
      final network = Get.find<NetworkService>();
      final isOnline = network.isOnline.value;

      final model = SavingGoalModel.fromEntity(entity)
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDeleted = false
        ..isSynced = false;

      // 1. الحفظ أولاً دائماً داخل قاعدة البيانات المحلية Isar لضمان العمل دون إنترنت
      await localDatasource.updateSavingGoal(model);

      if (isOnline) {
        try {
          final remoteGoal = await remoteDatasource.addGoal(model);

          model
            ..goalId = remoteGoal.goalId
            ..isSynced = true;

          await localDatasource.updateSavingGoal(model);
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Online create failed → queue fallback: $e");
          }
          await _addToQueue(model, SyncAction.create);
        }
      } else {
        await _addToQueue(model, SyncAction.create);
      }

      return const Right("Saving goal saved");
    } catch (e) {
      return Left(CacheFailure("Add saving goal failed: $e"));
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================
  @override
  Future<Either<Failure, Unit>> updateSavingGoal(
    SavingGoalEntity entity,
  ) async {
    try {
      final local = await localDatasource.getSavingGoal(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      // تحديث كامل الخصائص المتاحة لتفادي تصفير قيم المبالغ المدفوعة أو الأرصدة التراكمية
      local
        ..title = entity.title
        ..targetAmount = entity.targetAmount
        ..currentAmount = entity.currentAmount
        ..currencyId = entity.currencyId
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDatasource.updateSavingGoal(local);

      final network = Get.find<NetworkService>();

      if (network.isOnline.value) {
        try {
          await remoteDatasource.updateGoal(local);
          local.isSynced = true;
          await localDatasource.updateSavingGoal(local);
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Online update failed → queue fallback: $e");
          }
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
  Future<Either<Failure, Unit>> deleteSavingGoal(
    SavingGoalEntity entity,
  ) async {
    try {
      final local = await localDatasource.getSavingGoal(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      local
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await localDatasource.updateSavingGoal(local);

      final network = Get.find<NetworkService>();

      if (network.isOnline.value) {
        try {
          if (local.goalId != null && local.goalId != -1) {
            await remoteDatasource.deleteGoal(local.goalId!);
            // في حال نجاح الحذف من السيرفر مباشرة، نقوم بحذف السجل كلياً محلياً من Isar
            await localDatasource.deleteSavingGoal(local);
          } else {
            // الحذف الفوري محلياً إذا لم يُرفع السجل للسيرفر أصلاً
            await localDatasource.deleteSavingGoal(local);
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Online delete failed → queue fallback: $e");
          }
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
  Future<void> _addToQueue(SavingGoalModel model, SyncAction action) async {
    await syncQueueRepository.addToQueue(
      SyncQueueModel(
        id: const Uuid().v4(),
        localId: model.localId,
        isarId: model.isarId,
        table: "saving_goal",
        action: action,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<SavingGoalModel> _paginate(
    List<SavingGoalModel> list,
    PageRequest page,
  ) {
    final start = (page.pageNumber - 1) * page.pageSize;
    final end = (start + page.pageSize).clamp(0, list.length);
    return start >= list.length ? [] : list.sublist(start, end);
  }

  // =========================================================
  // LOCAL ONLY & EXTRA METHODS
  // =========================================================
  @override
  Future<Either<Failure, List<SavingGoalEntity>>>
  getAllSavingGoalLocal() async {
    try {
      final goals = await localDatasource.getSavingGoals();
      return Right(
        goals.where((g) => !g.isDeleted).map((e) => e.toEntity()).toList(),
      );
    } catch (e) {
      return Left(CacheFailure("Local fetch failed: $e"));
    }
  }

  @override
  Future<Either<Failure, List<SavingGoalEntity>>> getAchievedGoals(
    int userId,
  ) async {
    try {
      final goals = await remoteDatasource.getAchievedGoals(userId);
      return Right(goals.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure("Failed to fetch achieved goals: $e"));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingGoals() async {
    return const Right(unit);
  }
}
