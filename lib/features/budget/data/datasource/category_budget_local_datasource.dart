import 'package:spendwise/features/budget/data/model/category_budget_model.dart';

abstract class CategoryBudgetLocalDatasource {
  Future<List<CategoryBudgetModel>?> getBudgets();

  Future<void> addBudget(CategoryBudgetModel budget);

  Future<void> updateBudget(CategoryBudgetModel budget);

  Future<void> deleteBudget(CategoryBudgetModel budget);

  Future<CategoryBudgetModel?> getBudgetByCategoryId(int categoryId);
  Future<CategoryBudgetModel?> getBudgetByIsarId(int isarId);
  Future<void> clear();
}
