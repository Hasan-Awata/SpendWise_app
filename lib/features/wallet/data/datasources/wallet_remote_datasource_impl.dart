import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class WalletRemoteDatasourceImpl implements WalletRemoteDatasource {
  final NetworkService network;

  WalletRemoteDatasourceImpl({required this.network});

  // =========================
  // GET WALLETS
  // =========================
  @override
  Future<List<WalletModel>?> getMyWallets() async {
    final result = await network.request(
      endpoint: ApiEndpoints.wallet,
      method: "GET",
    );

    final List list = result is Map && result["data"] is List
        ? result["data"]
        : result;

    return list.map((e) => WalletModel.fromJson(e)).toList();
  }

  // =========================
  // ADD WALLET
  // =========================
  @override
  Future<WalletModel> addWalet(WalletModel wallet) async {
    final result = await network.request(
      endpoint: ApiEndpoints.wallet,
      method: "POST",
      body: wallet.toJson(),
    );

    return WalletModel.fromJson(result);
  }

  // =========================
  // UPDATE WALLET
  // =========================
  @override
  Future<WalletModel?> updateWallet(WalletModel wallet) async {
    final result = await network.request(
      endpoint: "${ApiEndpoints.wallet}/${wallet.walletId}",
      method: "PATCH",
      body: wallet.toJson(),
    );

    return WalletModel.fromJson(result);
  }

  // =========================
  // DELETE WALLET
  // =========================
  @override
  Future<bool> deleteWallet(WalletModel wallet) async {
    try {
      await network.request(
        endpoint: "${ApiEndpoints.wallet}/${wallet.walletId}",
        method: "DELETE",
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
