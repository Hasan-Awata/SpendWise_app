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
  Future<WalletModel> addWalet(WalletModel wallet) async {
    try {
      final response = await dio.post(
        ApiEndpoints.addWallet,
        data: wallet.toJson(),
      );
      return WalletModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<PagedResponse<WalletModel>> getMyWallet(PageRequest page) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getWallets,
        queryParameters: {
          'PageNumber': page.pageNumber,
          'PageSize': page.pageSize,
        },
      );
      return PagedResponse<WalletModel>.fromJson(
        response.data,
        (json) => WalletModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception("Server Error: ${e.response?.data['message']}");
    }
    return Exception("Network Error: ${e.message}");
  }
}
