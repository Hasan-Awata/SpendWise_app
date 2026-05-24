import 'package:spendwise/features/budget/data/model/category_budget_model.dart';

abstract class CategoryBudgetRemoteDatasource {
  Future<List<CategoryBudgetModel>> getBudgets();

  Future<CategoryBudgetModel> addBudget(CategoryBudgetModel budget);

  Future<CategoryBudgetModel> updateBudget(CategoryBudgetModel budget);

  Future<bool> deleteBudget(int categoryId);
}
