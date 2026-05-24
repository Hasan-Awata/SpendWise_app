// =========================================================================
// CategoryBudgetSyncRepository
// Handles Sync Queue Operations
// =========================================================================

import 'package:spendwise/features/budget/data/datasource/category_budget_local_datasource.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_remote_datasource.dart';
import 'package:spendwise/features/budget/data/model/category_budget_model.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

class CategoryBudgetSyncRepository
    implements SyncRepository<CategoryBudgetModel> {
  final CategoryBudgetLocalDatasource local;

  final CategoryBudgetRemoteDatasource remote;

  CategoryBudgetSyncRepository({required this.local, required this.remote});

  // =========================================================================
  // CREATE
  // =========================================================================

  @override
  Future<void> createByLocalId(int localId) async {
    try {
      final budgets = await local.getBudgets();

      final budget = budgets.firstWhere((e) => e.isarId == localId);

      final remoteBudget = await remote.addBudget(budget);

      budget
        ..categoryBudgetId = remoteBudget.categoryBudgetId
        ..isSynced = true;

      await local.updateBudget(budget);
    } on Exception catch (_) {
      rethrow;
    }
  }

  // =========================================================================
  // UPDATE
  // =========================================================================

  @override
  Future<void> updateByLocalId(int localId) async {
    try {
      final budgets = await local.getBudgets();

      final budget = budgets.firstWhere((e) => e.isarId == localId);

      await remote.updateBudget(budget);

      budget.isSynced = true;

      await local.updateBudget(budget);
    } on Exception catch (_) {
      rethrow;
    }
  }

  // =========================================================================
  // DELETE
  // =========================================================================

  @override
  Future<void> deleteByLocalId(int localId) async {
    try {
      final budgets = await local.getBudgets();

      final budget = budgets.firstWhere((e) => e.isarId == localId);

      bool removed = false;

      if (budget.categoryBudgetId != null && budget.categoryBudgetId != -1) {
        removed = await remote.deleteBudget(budget.categoryId);
      }

      if (removed) {
        await local.deleteBudget(budget);
      }
    } on Exception catch (_) {
      rethrow;
    }
  }
}
