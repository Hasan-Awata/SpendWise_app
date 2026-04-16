// // Contract: features/expense/data/datasources/expense_local_datasource.dart
import 'package:spendwise/features/expense/data/models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<void> init();
  Future<void> saveExpenses(List<ExpenseModel> expenses);
  Future<void> addExpense(ExpenseModel expense);
  Future<List<ExpenseModel>> getExpenses();
  Future<void> deleteExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> clear();
}
