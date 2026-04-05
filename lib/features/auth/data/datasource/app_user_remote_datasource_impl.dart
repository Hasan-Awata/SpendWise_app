// lib/features/auth/data/datasources/app_user_remote_datasource_impl.dart

import 'package:dio/dio.dart';
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/auth/data/models/login_dto.dart';
import 'package:spendwise/features/auth/data/models/signup_dto.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';
import '../models/user_model.dart';
import 'app_user_remote_datasource.dart';

class AppUserRemoteDatasourceImpl implements AppUserRemoteDatasource {
  final Dio dio;

  AppUserRemoteDatasourceImpl({required this.dio});

  @override
  Future<UserModel> register(SignupParams params) async {
    try {
      final dto = SignupDto.fromParams(params);
      // إرسال كائن UserDto بعد تحويله لـ JSON
      final response = await dio.post(
        ApiEndpoints.register,
        data: dto.toJson(),
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> logIn(LoginParams params) async {
    try {
      final dto = LoginDto.fromParams(params);
      final response = await dio.post(ApiEndpoints.login, data: dto.toJson());

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // دالة بسيطة للتعامل مع أخطاء Dio
  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception("Server Error: ${e.response?.data['message']}");
    }
    return Exception("Network Error: ${e.message}");
  }
}
