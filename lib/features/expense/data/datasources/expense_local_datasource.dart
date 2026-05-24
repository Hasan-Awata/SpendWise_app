// // Contract: features/expense/data/datasources/expense_local_datasource.dart
import 'package:spendwise/features/expense/data/models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<void> saveExpenses(List<ExpenseModel> expenses);
  Future<void> addExpense(ExpenseModel expense);
  Future<List<ExpenseModel>> getExpenses();
  Future<ExpenseModel?> getExpense(String localId);
  Future<ExpenseModel?> getExpenseByIsarId(int isarId);
  Future<void> saveOrUpdateExpense(ExpenseModel model);
  ExpenseModel? getExpenseByServerId(int? walletId);
  Future<bool> checkIfExpenseExists(String localId);
  Future<void> deleteExpense(ExpenseModel expense);
  Future<bool> checkIfExpenseExistsById(int? id);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> clear();
}
