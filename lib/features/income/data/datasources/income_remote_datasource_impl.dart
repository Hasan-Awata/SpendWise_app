import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomeRemoteDatasourceImpl implements IncomeRemoteDatasource {
  final http.Client client; // نستخدم Client بدلاً من Dio

  IncomeRemoteDatasourceImpl({required this.client});

  @override
  Future<PagedResponse<IncomeModel>> getMyIncomes(
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

    final headers = await ApiEndpoints().getHeaders();

    final response = await client.get(url, headers: headers);

    print("GetIncomes Response [${response.statusCode}]: ${response.body}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("Getincomes Success: تم جلب المصاريف");
      final decodedData = jsonDecode(response.body);

      return PagedResponse<IncomeModel>.fromJson(
        decodedData,
        (json) => IncomeModel.fromJson(json),
      );
    } else {
      print("Getincomes Error [${response.statusCode}]: ${response.body}");
      throw Exception("فشل جلب المصاريف من السيرفر");
    }
  }

  // // تعليق: إرسال بيانات الدخل الجديد للسيرفر والتحقق من حالة الاستجابة وتصريح الدخول
  @override
  Future<IncomeModel> addIncome(IncomeModel income) async {
    print("income is -----> ${income.toString()}}");
    final uri = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.income}");
    final header = await ApiEndpoints().getHeaders();

    final response = await client
        .post(uri, headers: header, body: jsonEncode(income.toJson()))
        .timeout(Duration(seconds: 15));
    print("ressssssssssssssssssssssssspo ${response.body}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return IncomeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('فشل الإرسال للسيرفر: ${response.statusCode}');
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
        .timeout(Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return IncomeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
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
        .timeout(Duration(seconds: 10));
    print("Delete Income Response [${response.statusCode}]: ${response.body}");
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
