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
      final response = await dio.get(
        "${ApiEndpoints.getIncomeByUser}/$userId",
        queryParameters: {
          'PageNumber': page.pageNumber,
          'PageSize': page.pageSize,
        },
      );

      return PagedResponse<IncomeModel>.fromJson(
        response.data,
        (json) => IncomeModel.fromJson(json),
      );
    } on DioException {
      // نمرر الخطأ كما هو ليقوم الـ Repository بتحويله لـ Failure
      rethrow;
    }
  }

  @override
  Future<IncomeModel> addIncome(IncomeModel income) async {
    try {
      final response = await dio.post(
        ApiEndpoints.addIncome,
        data: income.toJson(),
      );
      return IncomeModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<IncomeModel> updateIncome(int incomeId, IncomeModel income) async {
    try {
      final response = await dio.patch(
        "${ApiEndpoints.updateIncome}/$incomeId",
        data: income.toJson(),
      );
      return IncomeModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<bool> deleteIncome(int incomeId) async {
    try {
      final response = await dio.delete(
        "${ApiEndpoints.deleteIncome}/$incomeId",
      );

      // التحقق من النجاح بناءً على محتوى الرد أو كود الحالة
      if (response.data is bool) {
        return response.data;
      }
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      rethrow;
    }
  }
}
