import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final NetworkService network;

  ExpenseRemoteDataSourceImpl({required this.network});

  // =========================
  // GET EXPENSES
  // =========================
  @override
  Future<PagedResponse<ExpenseModel>?> getMyExpenses(
    int userId,
    PageRequest page,
  ) async {
    final result = await network.request(
      endpoint: ApiEndpoints.expense,
      method: "GET",
      queryParameters: {
        "UserId": userId,
        "PageNumber": page.pageNumber,
        "PageSize": page.pageSize,
      },
    );

    return PagedResponse<ExpenseModel>.fromJson(
      result,
      (json) => ExpenseModel.fromJson(json),
    );
  }

  // =========================
  // ADD EXPENSE
  // =========================
  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    print("THE DATA REQUEST IS ${expense.toString()}");
    final result = await network.request(
      endpoint: ApiEndpoints.expense,
      method: "POST",
      body: expense.toJson(),
    );

    return ExpenseModel.fromJson(result);
  }

  // =========================
  // UPDATE EXPENSE
  // =========================
  @override
  Future<ExpenseModel?> updateExpense(ExpenseModel expense) async {
    final result = await network.request(
      endpoint: "${ApiEndpoints.expense}/${expense.id}",
      method: "PATCH",
      body: expense.toJson(),
    );

    if (result == null) return expense;

    return ExpenseModel.fromJson(result);
  }

  // =========================
  // DELETE EXPENSE
  // =========================
  @override
  Future<bool> deleteExpense(ExpenseModel expense) async {
    try {
      await network.request(
        endpoint: "${ApiEndpoints.expense}/${expense.id}",
        method: "DELETE",
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
