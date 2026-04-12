/* تنفيذ العمليات باستخدام مكتبة Dio للتواصل مع الـ Endpoints */

import 'package:dio/dio.dart';
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomeRemoteDatasourceImpl implements IncomeRemoteDatasource {
  final Dio dio;
  IncomeRemoteDatasourceImpl({required this.dio});

  @override
  Future<PagedResponse<IncomeModel>> getMyIncomes(
    int userId,
    PageRequest page,
  ) async {
    try {
      // نمرر الـ userId والـ pagination
      final response = await dio.get(
        "${ApiEndpoints.getIncomeByUser}/$userId", // أو حسب المسار المحدد في الـ API
        queryParameters: {
          'PageNumber': page.pageNumber,
          'PageSize': page.pageSize,
        },
      );

      return PagedResponse<IncomeModel>.fromJson(
        response.data,
        (json) => IncomeModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<IncomeModel?> addIncome(IncomeModel income) async {
    try {
      final response = await dio.post(
        ApiEndpoints.addIncome,
        data: income.toJson(),
      );
      return IncomeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // دالة موحدة لمعالجة أخطاء الـ Dio
  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception(
        "Server Error: ${e.response?.data['message'] ?? 'Unknown Error'}",
      );
    }
    return Exception("Network Error: ${e.message}");
  }

  @override
  Future<IncomeModel?> updateIncome(int incomeId, IncomeModel income) async {
    try {
      final response = await dio.patch(
        "${ApiEndpoints.updateIncome}/$incomeId",
        data: income.toJson(),
      );
      return IncomeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<bool> deleteIncome(int incomeId) async {
    try {
      final response = await dio.delete(
        "${ApiEndpoints.deleteIncome}/$incomeId",
      );

      if (response.data is bool) {
        return response.data;
      }

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
