import 'package:spendwise/features/budget/data/datasource/category_budget_local_datasource.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_remote_datasource.dart';
import 'package:spendwise/features/budget/data/model/category_budget_model.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

class CategoryBudgetSyncRepository
    implements SyncRepository<CategoryBudgetModel> {
  final CategoryBudgetLocalDatasource local;
  final CategoryBudgetRemoteDatasource remote;

  CategoryBudgetSyncRepository({required this.local, required this.remote});

  @override
  Future<void> createByLocalId(int localId) async {
    final budget = await local.getBudgetByIsarId(localId);
    if (budget == null) return;

    // 🔴 منع التكرار
    if (budget.isSynced == true && budget.categoryBudgetId != null) return;

    try {
      final remoteBudget = await remote.addBudget(budget);

      budget
        ..categoryBudgetId = remoteBudget.categoryBudgetId
        ..isSynced = true;

      await local.updateBudget(budget);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateByLocalId(int localId) async {
    final budget = await local.getBudgetByIsarId(localId);
    if (budget == null) return;

    // 🔴 لا يحدث إذا غير مرفوع
    if (budget.categoryBudgetId == null) return;

    try {
      await remote.updateBudget(budget);

      budget.isSynced = true;
      await local.updateBudget(budget);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteByLocalId(int localId) async {
    final budget = await local.getBudgetByIsarId(localId);
    if (budget == null) return;

    try {
      bool removed = false;

      // 🔴 إذا لم يُرفع للسيرفر → حذف محلي فقط
      if (budget.categoryBudgetId == null || budget.categoryBudgetId == -1) {
        await local.deleteBudget(budget);
        return;
      }

      // ⚠️ تصحيح مهم: استخدام id الصحيح
      removed = await remote.deleteBudget(budget.categoryBudgetId!);

      if (removed) {
        await local.deleteBudget(budget);
      }
    } catch (e) {
      rethrow;
    }
  }
}
