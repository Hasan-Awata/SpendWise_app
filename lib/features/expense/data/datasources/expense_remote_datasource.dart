// // Contract: features/expense/data/datasources/expense_remote_datasource.dart
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

abstract class ExpenseRemoteDataSource {
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<PagedResponse<ExpenseModel>> getMyExpenses(
    int userId,
    PageRequest page,
  );
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<bool> deleteExpense(ExpenseModel expense);
}
