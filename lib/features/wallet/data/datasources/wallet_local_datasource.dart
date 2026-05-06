import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

abstract class WalletLocalDatasource {
  Future<void> init();
  Future<void> addWaletLocal(WalletModel wallet);
  WalletModel? getWallet(int id);
  Future<List<WalletModel>> myWallets();
  Future<void> deleteWallet(WalletModel wallet);
  Future<void> updateWallet(WalletModel wallet);
  Future<void> clearWallets();
}
