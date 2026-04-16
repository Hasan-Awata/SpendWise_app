// Implementation for WalletRemoteDatasource with clean design pattern
import 'package:dio/dio.dart';
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class WalletRemoteDatasourceImpl implements WalletRemoteDatasource {
  final Dio dio;
  WalletRemoteDatasourceImpl({required this.dio});

  @override
  Future<PagedResponse<WalletModel>> getMyWallet(PageRequest page) async {
    try {
      final response = await dio.get(ApiEndpoints.wallet);
      if (response.data is List) {
        List<dynamic> data = response.data;
        final wallets = data.map((json) => WalletModel.fromJson(json)).toList();

        return PagedResponse<WalletModel>(
          data: wallets,
          totalRecords: wallets.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: 1,
        );
      } else {
        throw Exception("تنسيق البيانات غير مدعوم من السيرفر");
      }
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<WalletModel> addWalet(WalletModel wallet) async {
    try {
      final response = await dio.post(
        ApiEndpoints.wallet,
        data: wallet.toJson(),
      );

      // print("wallet status is => ${response.statusCode}");
      return WalletModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<WalletModel> updateWallet(WalletModel wallet) async {
    try {
      final response = await dio.patch(
        "${ApiEndpoints.wallet}/${wallet.walletId}",
        data: wallet.toJson(),
      );
      return WalletModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<bool> deleteWallet(WalletModel wallet) async {
    try {
      final response = await dio.delete(
        "${ApiEndpoints.wallet}/${wallet.walletId}",
      );

      if (response.data is bool) {
        return response.data;
      }
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      rethrow;
    }
  }
}
