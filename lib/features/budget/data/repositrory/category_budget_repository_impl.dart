// =========================================================================
// CategoryBudgetRepositoryImpl
// Offline First + Unified Sync Queue
// =========================================================================

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_local_datasource.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_remote_datasource.dart';
import 'package:spendwise/features/budget/data/model/category_budget_model.dart';
import 'package:spendwise/features/budget/data/repositrory/category_budget_repository.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:uuid/uuid.dart';

class CategoryBudgetRepositoryImpl implements CategoryBudgetRepository {
  final CategoryBudgetLocalDatasource local;
  final CategoryBudgetRemoteDatasource remote;
  final SyncQueueRepository syncQueueRepository;

  CategoryBudgetRepositoryImpl({
    required this.local,
    required this.remote,
    required this.syncQueueRepository,
  });

  // =========================================================================
  // GET
  // =========================================================================

  @override
  Future<Either<Failure, List<CategoryBudgetEntity>>> getBudgets() async {
    try {
      final networkService = Get.find<NetworkService>();

      final isOnline = networkService.isOnline.value;

      if (isOnline) {
        try {
          if (kDebugMode) {
            print("📡 Fetching category budgets from remote...");
          }

          final remoteBudgets = await remote.getBudgets();
          print("RAW LENGTH FROM SERVER = ${remoteBudgets.length}");

          await local.clear();

          for (final budget in remoteBudgets) {
            print("budgte ------ >>> ${budget.categoryId}");
            budget
              ..isDeleted = false
              ..isSynced = true;

            await local.addBudget(budget);
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Remote category budget sync failed: $e");
          }
        }
      }

      final localData = await local.getBudgets();

      final filtered = localData.where((e) => !e.isDeleted).toList();

      final entities = filtered.map((e) => e.toEntity()).toList();

      return Right(entities);
    } catch (e) {
      return Left(
        CacheFailure("فشل تحميل ميزانيات التصنيفات: ${e.toString()}"),
      );
    }
  }

  // =========================================================================
  // ADD
  // =========================================================================

  @override
  Future<Either<Failure, String>> addBudget(CategoryBudgetEntity budget) async {
    try {
      final model = CategoryBudgetModel.fromEntity(budget)
        ..isDeleted = false
        ..isSynced = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await local.addBudget(model);

      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: model.localId,
          action: SyncAction.create,
          table: "category_budget",
          createdAt: DateTime.now(),
          isarId: model.isarId,
        ),
      );

      return const Right("تم حفظ الميزانية محلياً وبانتظار المزامنة");
    } catch (e) {
      return Left(CacheFailure("فشل إضافة الميزانية: ${e.toString()}"));
    }
  }

  // =========================================================================
  // UPDATE
  // =========================================================================

  @override
  Future<Either<Failure, Unit>> updateBudget(
    CategoryBudgetEntity entity,
  ) async {
    try {
      final localBudget = await local.getBudgetByCategoryId(entity.categoryId);

      if (localBudget == null) {
        return Left(CacheFailure("الميزانية غير موجودة للتعديل"));
      }

      localBudget
        ..percentageLimit = entity.percentageLimit
        ..percentageProgress = entity.percentageProgress
        ..moneyLimit = entity.moneyLimit
        ..spendingProgress = entity.spendingProgress
        ..startDate = entity.startDate
        ..endDate = entity.endDate
        ..isActive = entity.isActive
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await local.addBudget(localBudget);

      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: localBudget.localId,
          action: SyncAction.update,
          table: "category_budget",
          createdAt: DateTime.now(),
          isarId: localBudget.isarId,
        ),
      );

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل تعديل الميزانية: ${e.toString()}"));
    }
  }

  // =========================================================================
  // DELETE
  // =========================================================================

  @override
  Future<Either<Failure, Unit>> deleteBudget(
    CategoryBudgetEntity entity,
  ) async {
    try {
      final localBudget = await local.getBudgetByCategoryId(entity.categoryId);

      if (localBudget == null) {
        return Left(CacheFailure("الميزانية غير موجودة للحذف"));
      }

      localBudget
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await local.updateBudget(localBudget);

      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: localBudget.localId,
          action: SyncAction.delete,
          table: "category_budget",
          createdAt: DateTime.now(),
          isarId: localBudget.isarId,
        ),
      );

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل حذف الميزانية: ${e.toString()}"));
    }
  }
}
