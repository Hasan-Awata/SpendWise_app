import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomeRemoteDatasourceImpl implements IncomeRemoteDatasource {
  final http.Client client;
  final Duration timeoutDuration = const Duration(seconds: 10);

  IncomeRemoteDatasourceImpl({required this.client});

  @override
  Future<PagedResponse<IncomeModel>?> getMyIncomes(
    int userId,
    PageRequest page,
  ) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.income}")
        .replace(
          queryParameters: {
            'PageNumber': page.pageNumber.toString(),
            'PageSize': page.pageSize.toString(),
          },
        );

    try {
      final headers = await ApiEndpoints().getHeaders();
      final response = await client
          .get(url, headers: headers)
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return PagedResponse<IncomeModel>.fromJson(
          jsonDecode(response.body),
          (json) => IncomeModel.fromJson(json),
        );
      } else {
        throw Exception("فشل جلب الدخل: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال بالسيرفر: $e");
    }
  }

  @override
  Future<IncomeModel> addIncome(IncomeModel income) async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.income}");
    final header = await ApiEndpoints().getHeaders();

    final response = await client
        .post(uri, headers: header, body: jsonEncode(income.toJson()))
        .timeout(const Duration(seconds: 10));
    print(
      "income is: ${income.toString()}  \nincome response is --------->>>>  ${response.body}  status code: ${response.statusCode}",
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return IncomeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('فشل الإضافة: ${response.statusCode}');
    }
  }

  @override
  Future<IncomeModel> updateIncome(IncomeModel income) async {
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.income}/${income.id}",
    );
    final header = await ApiEndpoints().getHeaders();

    final response = await client
        .patch(uri, headers: header, body: jsonEncode(income.toJson()))
        .timeout(timeoutDuration);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return IncomeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("فشل التحديث: ${response.body}");
    }
  }

  @override
  Future<bool> deleteIncome(IncomeModel income) async {
    if (income.id == null) return true;
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.income}/${income.id}",
    );
    final header = await ApiEndpoints().getHeaders();

    final response = await client
        .delete(uri, headers: header)
        .timeout(timeoutDuration);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      return false;
    }
  }
}
