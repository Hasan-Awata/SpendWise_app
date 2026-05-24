import 'dart:async'; // تم استيرادها لاستخدام TimeoutException
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class WalletRemoteDatasourceImpl implements WalletRemoteDatasource {
  final http.Client client;
  final Duration timeoutDuration = const Duration(seconds: 7);

  WalletRemoteDatasourceImpl({required this.client});

  @override
  Future<List<WalletModel>?> getMyWallets() async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}");

    try {
      final headers = await ApiEndpoints().getHeaders();
      final response = await client
          .get(url, headers: headers)
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => WalletModel.fromJson(json)).toList();
      } else {
        throw Exception("فشل جلب البيانات: ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception("انتهت مهلة الاتصال");
    } catch (e) {
      throw Exception("خطأ في جلب البيانات: $e");
    }
  }

  @override
  Future<WalletModel> addWalet(WalletModel wallet) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}");
    final headers = await ApiEndpoints().getHeaders();

    try {
      final response = await client
          .post(url, headers: headers, body: jsonEncode(wallet.toJson()))
          .timeout(timeoutDuration);
      print(
        "response is is is is wallet ${response.body} status:${response.statusCode}",
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return WalletModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("فشل إضافة المحفظة: ${response.body}");
      }
    } catch (e) {
      throw Exception("خطأ في الإضافة: $e");
    }
  }

  @override
  Future<WalletModel?> updateWallet(WalletModel wallet) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}/${wallet.walletId}",
    );
    final headers = await ApiEndpoints().getHeaders();

    try {
      final response = await client
          .patch(url, headers: headers, body: jsonEncode(wallet.toJson()))
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isEmpty
            ? null
            : WalletModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception("خطأ في التحديث: $e");
    }
  }

  @override
  Future<bool> deleteWallet(WalletModel wallet) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}/${wallet.walletId}",
    );
    final headers = await ApiEndpoints().getHeaders();

    final response = await client
        .delete(url, headers: headers)
        .timeout(timeoutDuration);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      return false;
    }
  }
}
