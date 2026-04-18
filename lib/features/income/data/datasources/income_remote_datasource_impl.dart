// import 'package:dio/dio.dart';
// import 'package:spendwise/core/network/api_endpoints.dart';
// import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
// import 'package:spendwise/features/income/data/models/income_model.dart';
// import 'package:spendwise/features/pages/data/model/page_response.dart';
// import 'package:spendwise/features/pages/domain/entities/page_request.dart';
// class IncomeRemoteDatasourceImpl implements IncomeRemoteDatasource {
//   final Dio dio;
//   IncomeRemoteDatasourceImpl({required this.dio});
//   @override
//   Future<PagedResponse<IncomeModel>> getMyIncomes(
//     int userId,
//     PageRequest page,
//   ) async {
//     try {
//       final response = await dio.get(
//         ApiEndpoints.income,
//         queryParameters: {
//           'PageNumber': page.pageNumber,
//           'PageSize': page.pageSize,
//         },
//       );
//       return PagedResponse<IncomeModel>.fromJson(
//         response.data,
//         (json) => IncomeModel.fromJson(json),
//       );
//     } on DioException {
//       // نمرر الخطأ كما هو ليقوم الـ Repository بتحويله لـ Failure
//       rethrow;
//     }
//   }
//   @override
//   Future<IncomeModel> addIncome(IncomeModel income) async {
//     try {
//       final response = await dio.post(
//         ApiEndpoints.income,
//         data: income.toJson(),
//       );
//       return IncomeModel.fromJson(response.data);
//     } on DioException {
//       rethrow;
//     }
//   }
//   @override
//   Future<IncomeModel> updateIncome(IncomeModel income) async {
//     try {
//       final response = await dio.patch(
//         "${ApiEndpoints.income}/${income.remoteId}",
//         data: income.toJson(),
//       );
//       return IncomeModel.fromJson(response.data);
//     } on DioException {
//       rethrow;
//     }
//   }
//   @override
//   Future<bool> deleteIncome(IncomeModel income) async {
//     try {
//       final response = await dio.delete(
//         "${ApiEndpoints.income}/${income.remoteId}",
//       );
//       // التحقق من النجاح بناءً على محتوى الرد أو كود الحالة
//       if (response.data is bool) {
//         return response.data;
//       }
//       return response.statusCode == 200 || response.statusCode == 204;
//     } on DioException {
//       rethrow;
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomeRemoteDatasourceImpl implements IncomeRemoteDatasource {
  final http.Client client; // نستخدم Client بدلاً من Dio

  IncomeRemoteDatasourceImpl({required this.client});

  Future<Map<String, String>> _getHeaders() async {
    final user = await AppUserLocalDatasourceImpl().getUser();
    final String? token = user?.token ?? CurrentUser.token;
    if (token == null) throw Exception("Unauthorized");
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<PagedResponse<IncomeModel>> getMyIncomes(
    int userId,
    PageRequest page,
  ) async {
    // بناء الرابط مع الـ Query Parameters
    final queryParameters = {
      'PageNumber': page.pageNumber.toString(),
      'PageSize': page.pageSize.toString(),
    };

    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}/${ApiEndpoints.income}",
    ).replace(queryParameters: queryParameters);
    final headers = await _getHeaders();
    final response = await client
        .get(uri, headers: headers)
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      return PagedResponse<IncomeModel>.fromJson(
        jsonDecode(response.body),
        (json) => IncomeModel.fromJson(json),
      );
    } else {
      throw Exception(response.body);
    }
  }

  // // تعليق: إرسال بيانات الدخل الجديد للسيرفر والتحقق من حالة الاستجابة وتصريح الدخول
  @override
  Future<IncomeModel> addIncome(IncomeModel income) async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.income}");
    final header = await _getHeaders();

    final response = await client
        .post(uri, headers: header, body: jsonEncode(income.toJson()))
        .timeout(Duration(seconds: 10));
    print("ressssssssssssssssssssssssspo ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
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

    final header = await _getHeaders();
    final response = await client
        .patch(uri, headers: header, body: jsonEncode(income.toJson()))
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
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
    final header = await _getHeaders();
    final response = await client
        .delete(uri, headers: header)
        .timeout(Duration(seconds: 10));

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
