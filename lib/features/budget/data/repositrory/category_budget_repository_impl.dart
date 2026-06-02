// =========================================================================
// CategoryBudgetRepositoryImpl
// Offline First + Unified Sync Queue
// =========================================================================

import 'package:dartz/dartz.dart';
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

  @override
  Future<Either<Failure, List<CategoryBudgetEntity>>> getBudgets() async {
    try {
      final networkService = Get.find<NetworkService>();

      final isOnline = networkService.isOnline.value;

      if (isOnline) {
        try {
          final remoteBudgets = await remote.getBudgets();

          for (final budget in remoteBudgets) {
            budget
              ..isDeleted = false
              ..isSynced = true;

            final existing = await local.getBudgetByCategoryId(
              budget.categoryId,
            );

            if (existing == null) {
              await local.addBudget(budget);
            } else {
              budget
                ..isarId = existing.isarId
                ..localId = existing.localId;

              await local.updateBudget(budget);
            }
          }
        } catch (e) {
          final localData = await local.getBudgets() ?? [];
          final filtered = localData.where((e) => !e.isDeleted).toList()
            ..sort((a, b) => b.startDate.compareTo(a.startDate));
          return Right(filtered.map((e) => e.toEntity()).toList());
        }
      }

      final localData = await local.getBudgets() ?? [];
      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
      return Right(filtered.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure("Failed to load budgets: $e"));
    }
  }

  @override
  Future<Either<Failure, CategoryBudgetEntity?>> getActiveBudgetForCategory(
    int categoryId,
  ) async {
    try {
      // تعليق: نقوم بجلب الميزانية النشطة للفئة المختارة محلياً لسرعة الوصول
      final localData = await local.getBudgets() ?? [];
      final activeBudget = localData.firstWhere(
        (b) => b.categoryId == categoryId && b.isActive && !b.isDeleted,
      );

      return Right(activeBudget.toEntity());
    } catch (e) {
      return Left(CacheFailure("Failed to get budget: $e"));
    }
  }

  // =========================================================
  // ADD (Offline-first + immediate sync if online)
  // =========================================================
  @override
  Future<Either<Failure, String>> addBudget(CategoryBudgetEntity budget) async {
    try {
      final model = CategoryBudgetModel.fromEntity(budget)
        ..isDeleted = false
        ..isSynced = false
        ..moneyLimit = budget.moneyLimit
        ..spendingProgress = budget.spendingProgress
        ..startDate = budget.startDate
        ..endDate = budget.endDate;
      // 1. save locally
      await local.addBudget(model);

      final isOnline = Get.find<NetworkService>().isOnline.value;

      if (isOnline) {
        try {
          final remoteBudget = await remote.addBudget(model);

          model
            ..categoryBudgetId = remoteBudget.categoryBudgetId
            ..isSynced = true;

          await local.updateBudget(model);
        } catch (e) {
          // fallback -> queue
          await _addToQueue(model.localId, SyncAction.create, model.isarId);
        }
      } else {
        // offline -> queue
        await _addToQueue(model.localId, SyncAction.create, model.isarId);
      }

      return const Right("Budget saved");
    } catch (e) {
      return Left(CacheFailure("Add budget failed: $e"));
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================
  @override
  Future<Either<Failure, Unit>> updateBudget(
    CategoryBudgetEntity entity,
  ) async {
    try {
      final localBudget = await local.getBudgetByCategoryId(entity.categoryId);

      if (localBudget == null) {
        return Left(CacheFailure("Budget not found"));
      }

      localBudget
        ..percentageLimit = entity.percentageLimit
        ..percentageProgress = entity.percentageProgress
        ..moneyLimit = entity
            .moneyLimit // أضف هذه
        ..spendingProgress = entity
            .spendingProgress // أضف هذه
        ..startDate = entity.startDate
        ..endDate = entity.endDate
        ..isActive = entity.isActive
        ..isSynced = false;

      await local.updateBudget(localBudget);

      final isOnline = Get.find<NetworkService>().isOnline.value;

      if (isOnline) {
        try {
          await remote.updateBudget(localBudget);
          localBudget.isSynced = true;
          await local.updateBudget(localBudget);
        } catch (e) {
          await _addToQueue(
            localBudget.localId,
            SyncAction.update,
            localBudget.isarId,
          );
        }
      } else {
        await _addToQueue(
          localBudget.localId,
          SyncAction.update,
          localBudget.isarId,
        );
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
  Future<Either<Failure, Unit>> deleteBudget(
    CategoryBudgetEntity entity,
  ) async {
    try {
      final localBudget = await local.getBudgetByCategoryId(entity.categoryId);

      if (localBudget == null) {
        return Left(CacheFailure("Budget not found"));
      }

      localBudget
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await local.updateBudget(localBudget);

      final isOnline = Get.find<NetworkService>().isOnline.value;

      if (isOnline) {
        try {
          await remote.deleteBudget(localBudget.categoryId);
        } catch (e) {
          await _addToQueue(
            localBudget.localId,
            SyncAction.delete,
            localBudget.isarId,
          );
        }
      } else {
        await _addToQueue(
          localBudget.localId,
          SyncAction.delete,
          localBudget.isarId,
        );
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("Delete failed: $e"));
    }
  }

  // =========================================================
  // QUEUE HELPER
  // =========================================================
  Future<void> _addToQueue(
    String localId,
    SyncAction action,
    int isarId,
  ) async {
    await syncQueueRepository.addToQueue(
      SyncQueueModel(
        id: const Uuid().v4(),
        localId: localId,
        action: action,
        table: "category_budget",
        createdAt: DateTime.now(),
        isarId: isarId,
      ),
    );
  }
}
