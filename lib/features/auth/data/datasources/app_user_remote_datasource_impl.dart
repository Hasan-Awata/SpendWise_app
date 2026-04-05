// lib/features/auth/data/datasources/app_user_remote_datasource_impl.dart

import 'package:dio/dio.dart';
import 'package:spendwise/core/network/api_endpoints.dart';
import '../models/user_dto.dart';
import '../models/user_model.dart';
import 'app_user_remote_datasource.dart';

class AppUserRemoteDatasourceImpl implements AppUserRemoteDatasource {
  final Dio dio;

  AppUserRemoteDatasourceImpl({required this.dio});

  @override
  Future<UserModel> register(UserDto userDto) async {
    try {
      // إرسال كائن UserDto بعد تحويله لـ JSON
      final response = await dio.post(
        ApiEndpoints.register,
        data: userDto.toJson(),
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> logIn(String userName, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {"userName": userName, "password": password},
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logOut() async {
    await dio.post(ApiEndpoints.logout);
  }

  // دالة بسيطة للتعامل مع أخطاء Dio
  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception("Server Error: ${e.response?.data['message']}");
    }
    return Exception("Network Error: ${e.message}");
  }
}
