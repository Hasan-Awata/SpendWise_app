import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_remote_datasource.dart';
import 'package:spendwise/features/budget/data/model/category_budget_model.dart';

class CategoryBudgetRemoteDatasourceImpl
    implements CategoryBudgetRemoteDatasource {
  final http.Client client;

  CategoryBudgetRemoteDatasourceImpl({required this.client});

  final timeoutDuration = const Duration(seconds: 20);

  @override
  Future<List<CategoryBudgetModel>> getBudgets() async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.categories}");

    final headers = await ApiEndpoints().getHeaders();

    final response = await client
        .get(uri, headers: headers)
        .timeout(timeoutDuration);
    // print(
    //   "budget ---->>>> ${jsonDecode(response.body)} status ${response.statusCode}",
    // );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List decoded = jsonDecode(response.body);

      return decoded.map((e) => CategoryBudgetModel.fromJson(e)).toList();
    }

    throw Exception("فشل جلب الميزانيات");
  }

  @override
  Future<CategoryBudgetModel> addBudget(CategoryBudgetModel budget) async {
    print("add category budget  is --->: ${budget.toString()}");
    final uri = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.categories}");

    final headers = await ApiEndpoints().getHeaders();

    final response = await client
        .post(uri, headers: headers, body: jsonEncode(budget.toJson()))
        .timeout(timeoutDuration);

    print(
      "category budget  is --->: ${response.body} status:${response.statusCode}",
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CategoryBudgetModel.fromJson(jsonDecode(response.body));
    }

    throw Exception("فشل إضافة الميزانية");
  }

  @override
  Future<CategoryBudgetModel> updateBudget(CategoryBudgetModel budget) async {
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.categories}/${budget.categoryId}",
    );
    print("update category budget  is --->: ${budget.toString()}}");
    final headers = await ApiEndpoints().getHeaders();

    final response = await client
        .patch(uri, headers: headers, body: jsonEncode(budget.toJson()))
        .timeout(timeoutDuration);
    print(
      "update category budget  is --->: ${response.body} status:${response.statusCode}",
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return budget;
    }

    throw Exception("فشل تحديث الميزانية");
  }

  @override
  Future<bool> deleteBudget(int categoryId) async {
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.categories}/$categoryId",
    );

    final headers = await ApiEndpoints().getHeaders();

    final response = await client
        .delete(uri, headers: headers)
        .timeout(timeoutDuration);

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
