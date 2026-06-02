import 'package:isar/isar.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_local_datasource.dart';
import 'package:spendwise/features/budget/data/model/category_budget_model.dart';

class CategoryBudgetLocalDatasourceImpl
    implements CategoryBudgetLocalDatasource {
  final Isar isar;

  CategoryBudgetLocalDatasourceImpl(this.isar);

  @override
  Future<List<CategoryBudgetModel>?> getBudgets() async {
    return await isar.categoryBudgetModels.where().findAll();
  }

  @override
  Future<void> addBudget(CategoryBudgetModel budget) async {
    await isar.writeTxn(() async {
      // 1. البحث عن أي سجل موجود مسبقاً يحمل نفس الـ localId الفريد
      final existingBudget = await isar.categoryBudgetModels
          .filter()
          .localIdEqualTo(budget.localId)
          .findFirst();

      // 2. إذا وُجد السجل، نربط الـ isarId الخاص به لكي تتحول العملية إلى تعديل تلقائي بدلاً من إضافة مكررة
      if (existingBudget != null) {
        budget.isarId = existingBudget.isarId;
      }

      // 3. الآن الحفظ سيعمل بنجاح تام (إضافة إن كان جديداً، وتعديل إن كان قديماً) دون أي خطأ Index
      await isar.categoryBudgetModels.put(budget);
    });
  }

  @override
  Future<void> updateBudget(CategoryBudgetModel budget) async {
    await isar.writeTxn(() async {
      await isar.categoryBudgetModels.put(budget);
    });
  }

  @override
  Future<void> deleteBudget(CategoryBudgetModel budget) async {
    await isar.writeTxn(() async {
      await isar.categoryBudgetModels.delete(budget.isarId);
    });
  }

  @override
  Future<CategoryBudgetModel?> getBudgetByCategoryId(int categoryId) async {
    return await isar.categoryBudgetModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .findFirst();
  }

  @override
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.categoryBudgetModels.clear();
    });
  }

  @override
  Future<CategoryBudgetModel?> getBudgetByIsarId(int isarId) async {
    return await isar.categoryBudgetModels
        .filter()
        .isarIdEqualTo(isarId)
        .findFirst();
  }
}
