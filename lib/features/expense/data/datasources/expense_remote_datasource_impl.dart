import 'package:dio/dio.dart';
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final Dio dio;
  ExpenseRemoteDataSourceImpl({required this.dio});

  @override
  Future<PagedResponse<ExpenseModel>> getMyExpenses(
    int userId,
    PageRequest page,
  ) async {
    try {
      final response = await dio.get(
        "${ApiEndpoints.expense}/$userId",
        queryParameters: {
          'PageNumber': page.pageNumber,
          'PageSize': page.pageSize,
        },
      );

      return PagedResponse<ExpenseModel>.fromJson(
        response.data,
        (json) => ExpenseModel.fromJson(json),
      );
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    try {
      final response = await dio.post(
        ApiEndpoints.expense,
        data: expense.toJson(), // يرسل بيانات ExpenseDTO
      );
      return ExpenseModel.fromJson(
        response.data,
      ); // يستقبل بيانات ExpenseResponse
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      final response = await dio.patch(
        "${ApiEndpoints.expense}/${expense.id}",
        data: expense.toJson(),
      );
      return ExpenseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<bool> deleteExpense(ExpenseModel expense) async {
    try {
      final response = await dio.delete(
        "${ApiEndpoints.expense}/${expense.id}",
      );

      if (response.data is bool) {
        return response.data;
      }
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      rethrow;
    }
  }
}
