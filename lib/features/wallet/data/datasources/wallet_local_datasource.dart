import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

abstract class WalletLocalDatasource {
  Future<void> addWalletLocal(WalletModel wallet);
  WalletModel? getWallet(String localId);
  Future<List<WalletModel>> myWallets();
  WalletModel? getWalletByServerId(int? walletId);
  Future<bool> checkIfWalletExists(String localId);
  Future<void> deleteWallet(WalletModel wallet);
  Future<void> updateWallet(WalletModel wallet);
  Future<void> clearWallets();
}
