import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final http.Client client;
  ExpenseRemoteDataSourceImpl({required this.client});

  @override
  Future<PagedResponse<ExpenseModel>?> getMyExpenses(
    int userId,
    PageRequest page,
  ) async {
    // Build URL with pagination and userId parameters
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.expense}")
        .replace(
          queryParameters: {
            'UserId': userId.toString(), // ضمان إرسال معرف المستخدم للسيرفر
            'PageNumber': page.pageNumber.toString(),
            'PageSize': page.pageSize.toString(),
          },
        );

    final headers = await ApiEndpoints().getHeaders();

    final response = await client.get(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedData = jsonDecode(response.body);
      return PagedResponse<ExpenseModel>.fromJson(
        decodedData,
        (json) => ExpenseModel.fromJson(json),
      );
    } else {
      throw Exception("فشل جلب المصاريف من السيرفر: ${response.statusCode}");
    }
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.expense}");
    final headers = await ApiEndpoints().getHeaders();
    final body = jsonEncode(expense.toJson());

    final response = await client.post(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ExpenseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("فشل إضافة المصروف: ${response.body}");
    }
  }

  @override
  Future<ExpenseModel?> updateExpense(ExpenseModel expense) async {
    // API endpoint usually expects the remote ID for updates
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.expense}/${expense.id}",
    );
    final headers = await ApiEndpoints().getHeaders();
    final body = jsonEncode(expense.toJson());

    final response = await client.patch(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return expense;
      return ExpenseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("فشل تحديث المصروف: ${response.statusCode}");
    }
  }

  @override
  Future<bool> deleteExpense(ExpenseModel expense) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.expense}/${expense.id}",
    );
    final headers = await ApiEndpoints().getHeaders();

    final response = await client.delete(url, headers: headers);

    // Standard success codes for deletion are 200 (OK) or 204 (No Content)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      return false;
    }
  }
}
