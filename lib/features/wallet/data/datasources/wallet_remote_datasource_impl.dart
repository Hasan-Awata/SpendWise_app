import 'dart:convert';
import 'dart:async'; // تم استيرادها لاستخدام TimeoutException
import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class WalletRemoteDatasourceImpl implements WalletRemoteDatasource {
  final http.Client client;
  final Duration timeoutDuration = const Duration(
    seconds: 10,
  ); // تحديد مدة المهلة

  WalletRemoteDatasourceImpl({required this.client});

  Future<Map<String, String>> _getHeaders() async {
    final user = await AppUserLocalDatasourceImpl().getUser();
    final String? token;
    if (user != null) {
      token = user.token;
    } else {
      token = CurrentUser.token;
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<PagedResponse<WalletModel>> getMyWallet(PageRequest page) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}");
    final headers = await _getHeaders();

    try {
      final response = await client
          .get(url, headers: headers)
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final wallets = data.map((json) => WalletModel.fromJson(json)).toList();

        return PagedResponse<WalletModel>(
          data: wallets,
          totalRecords: wallets.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: 1,
        );
      } else {
        throw Exception("فشل جلب المحافظ: رمز الحالة ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception("انتهت مهلة الاتصال، يرجى التحقق من الإنترنت");
    }
  }

  @override
  Future<WalletModel> addWalet(WalletModel wallet) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}");
    final headers = await _getHeaders();
    final body = jsonEncode(wallet.toJson());

    try {
      final response = await client
          .post(url, headers: headers, body: body)
          .timeout(timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WalletModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("فشل إضافة المحفظة: ${response.body}");
      }
    } on TimeoutException {
      throw Exception("انتهت مهلة طلب الإضافة، يرجى المحاولة لاحقاً");
    }
  }

  @override
  Future<WalletModel> updateWallet(WalletModel wallet) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}/${wallet.walletId}",
    );
    final headers = await _getHeaders();
    final body = jsonEncode(wallet.toJson());

    try {
      final response = await client
          .patch(url, headers: headers, body: body)
          .timeout(timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WalletModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("فشل تحديث المحفظة: رمز الحالة ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception("انتهت مهلة التحديث، يرجى المحاولة لاحقاً");
    }
  }

  @override
  Future<bool> deleteWallet(WalletModel wallet) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}/${wallet.walletId}",
    );
    final headers = await _getHeaders();

    try {
      final response = await client
          .delete(url, headers: headers)
          .timeout(timeoutDuration);

      return response.statusCode == 200 || response.statusCode == 204;
    } on TimeoutException {
      return false; // نرجع false في حال انتهت المهلة
    } catch (_) {
      return false;
    }
  }
}
