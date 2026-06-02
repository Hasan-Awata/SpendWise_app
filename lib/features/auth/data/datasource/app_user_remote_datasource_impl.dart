import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/auth/data/models/login_dto.dart';
import 'package:spendwise/features/auth/data/models/signup_dto.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

import '../models/user_model.dart';
import 'app_user_local_datasource.dart';
import 'app_user_remote_datasource.dart';

class AppUserRemoteDatasourceImpl implements AppUserRemoteDatasource {
  final http.Client client;
  final AppUserLocalDatasource localDatasource;
  AppUserRemoteDatasourceImpl({
    required this.client,
    required this.localDatasource,
  });

  // // ميزة: دالة مساعدة لبناء الرابط الكامل لتقليل التكرار
  Uri _buildUri(String endpoint) {
    return Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
  }

  // // ميزة: ترويسة الطلبات الموحدة (Headers)
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<UserModel> register(SignupParams params) async {
    try {
      final dto = SignupDto.fromParams(params);

      final response = await client
          .post(
            _buildUri(ApiEndpoints.register),
            headers: _headers,
            body: jsonEncode(dto.toJson()),
          )
          .timeout(
            const Duration(seconds: 10),
          ); // // تعليق: مهلة زمنية 10 ثوانٍ لضمان استقرار الشبكة

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserModel.fromJson(_extractUserPayload(data));
      } else {
        throw Exception('فشل التسجيل: كود ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Register Remote Error: $e");
      rethrow;
    }
  }

  @override
  Future<UserModel> logIn(LoginParams params) async {
    try {
      final dto = LoginDto.fromParams(params);

      final response = await client
          .post(
            _buildUri(ApiEndpoints.login),
            headers: _headers,
            body: jsonEncode(dto.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Login Response Data: $data');
        return UserModel.fromJson(_extractUserPayload(data));
      } else {
        throw Exception('فشل تسجيل الدخول: كود ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Login Remote Error: $e");
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await client
          .post(_buildUri(ApiEndpoints.logout), headers: _headers)
          .timeout(
            const Duration(seconds: 7),
          ); // // تعليق: مهلة أقل لعملية تسجيل الخروج
    } catch (e) {
      print("⚠️ Logout Error (Ignored): $e");
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
    throw const FormatException('نسق استجابة المصادقة غير متوقع');
  }

  bool _hasUserFields(Map<String, dynamic> map) {
    return map.containsKey('UserId') ||
        map.containsKey('userId') ||
        map.containsKey('Token') ||
        map.containsKey('token') ||
        map.containsKey('refreshToken');
  }
}
