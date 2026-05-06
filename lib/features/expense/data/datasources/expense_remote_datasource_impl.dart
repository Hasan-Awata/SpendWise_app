/*
  Implementation for ExpenseRemoteDataSource using http with explicit logging.
  تأكد من مطابقة الروابط مع الـ Backend (UserId في المسار أم كـ Query Parameter)
*/

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final http.Client client;
  ExpenseRemoteDataSourceImpl({required this.client});

  // دالة موحدة لجلب التوكن وتجهيز الـ Headers
  Future<Map<String, String>> _getHeaders() async {
    final user = await AppUserLocalDatasourceImpl().getUser();
    final String token = user?.token ?? CurrentUser.token;

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<PagedResponse<ExpenseModel>> getMyExpenses(
    int userId,
    PageRequest page,
  ) async {
    // بناء الرابط مع الـ Query Parameters يدوياً في http
    final url =
        Uri.parse(
          "${ApiEndpoints.baseUrl}${ApiEndpoints.expense}/$userId",
        ).replace(
          queryParameters: {
            'PageNumber': page.pageNumber.toString(),
            'PageSize': page.pageSize.toString(),
          },
        );

    final headers = await _getHeaders();
    print("Fetching Expenses for user $userId from: $url");

    final response = await client.get(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("GetExpenses Success: تم جلب المصاريف");
      final decodedData = jsonDecode(response.body);

      return PagedResponse<ExpenseModel>.fromJson(
        decodedData,
        (json) => ExpenseModel.fromJson(json),
      );
    } else {
      print("GetExpenses Error [${response.statusCode}]: ${response.body}");
      throw Exception("فشل جلب المصاريف من السيرفر");
    }
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.expense}");
    final headers = await _getHeaders();
    final body = jsonEncode(expense.toJson());

    print("Sending Expense JSON: $body to $url");

    final response = await client.post(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("AddExpense Success: ${response.body}");
      return ExpenseModel.fromJson(jsonDecode(response.body));
    } else {
      print("AddExpense Error [${response.statusCode}]: ${response.body}");
      throw Exception("فشل إضافة المصروف: ${response.body}");
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.expense}/${expense.id}",
    );
    final headers = await _getHeaders();
    final body = jsonEncode(expense.toJson());

    print("Updating Expense ${expense.id} at: $url");

    final response = await client.patch(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("UpdateExpense Success");
      // ملاحظة: إذا كان السيرفر يعيد 204 No Content، قد تحتاج لإعادة الكائن نفسه
      if (response.body.isEmpty) return expense;
      return ExpenseModel.fromJson(jsonDecode(response.body));
    } else {
      print("UpdateExpense Error [${response.statusCode}]: ${response.body}");
      throw Exception("فشل تحديث المصروف");
    }
  }

  @override
  Future<bool> deleteExpense(ExpenseModel expense) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.expense}/${expense.id}",
    );
    final headers = await _getHeaders();

    print("Deleting Expense ID: ${expense.id} from: $url");

    final response = await client.delete(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      print("DeleteExpense Success");
      return true;
    } else {
      print("DeleteExpense Error [${response.statusCode}]: ${response.body}");
      return false;
    }
  }
}
