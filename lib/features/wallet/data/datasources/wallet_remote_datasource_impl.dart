import 'dart:async'; // تم استيرادها لاستخدام TimeoutException
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class WalletRemoteDatasourceImpl implements WalletRemoteDatasource {
  final http.Client client;
  final Duration timeoutDuration = const Duration(
    seconds: 7,
  ); // تحديد مدة المهلة

  WalletRemoteDatasourceImpl({required this.client});

  @override
  Future<PagedResponse<WalletModel>> getMyWallet(PageRequest page) async {
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}");
    final headers = await ApiEndpoints().getHeaders();

    try {
      final response = await client
          .get(url, headers: headers)
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
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
    final headers = await ApiEndpoints().getHeaders();
    final body = jsonEncode(wallet.toJson());

    print("wallettttttttttttttttttt :${wallet.toString()}");
    try {
      final response = await client
          .post(url, headers: headers, body: body)
          .timeout(timeoutDuration);

      print("statusCode: ${response.statusCode} body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return WalletModel.fromJson(jsonDecode(response.body));
      } else {
        print("statusCode: ${response.statusCode} body: ${response.body}");
        throw Exception("فشل إضافة المحفظة: ${response.body}");
      }
    } on TimeoutException {
      throw Exception("انتهت مهلة طلب الإضافة، يرجى المحاولة لاحقاً");
    }
  }

  @override
  Future<WalletModel?> updateWallet(WalletModel wallet) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}/${wallet.walletId}",
    );
    final headers = await ApiEndpoints().getHeaders();
    final body = jsonEncode(wallet.toJson());

    try {
      final response = await client
          .patch(url, headers: headers, body: body)
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          print("UpdateTag Success: تم تحديث التاج بنجاح (بدون محتوى)");
          return null;
        }
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
    print("deletete  ${wallet.toString()}");
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}/${wallet.walletId}",
    );
    final headers = await ApiEndpoints().getHeaders();

    try {
      final response = await client
          .delete(url, headers: headers)
          .timeout(timeoutDuration);

      print("deletete  ${response.body}  status code ${response.statusCode}");
      return response.statusCode >= 200 && response.statusCode < 300;
    } on TimeoutException {
      return false; // نرجع false في حال انتهت المهلة
    } catch (_) {
      return false;
    }
  }
}
