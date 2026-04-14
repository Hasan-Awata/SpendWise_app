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

      return UserModel.fromJson(_extractUserPayload(response.data));
    } on DioException catch (_) {
      rethrow;
      // throw _handleError(e);
    }
  }

  @override
  Future<UserModel> logIn(LoginParams params) async {
    try {
      final dto = LoginDto.fromParams(params);
      final response = await dio.post(ApiEndpoints.login, data: dto.toJson());
      print('Response Data: ${response.data}');
      return UserModel.fromJson(_extractUserPayload(response.data));
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await dio.post(ApiEndpoints.logout);
    } on DioException catch (_) {
      rethrow;
    }
  }

  Map<String, dynamic> _extractUserPayload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (_hasUserFields(raw)) return raw;

      final dynamic dataNode = raw['data'] ?? raw['result'] ?? raw['user'];
      if (dataNode is Map<String, dynamic>) {
        return dataNode;
      }
    }
    throw const FormatException('Unexpected auth response format');
  }

  bool _hasUserFields(Map<String, dynamic> map) {
    return map.containsKey('UserId') ||
        map.containsKey('userId') ||
        map.containsKey('Token') ||
        map.containsKey('token');
  }
}
