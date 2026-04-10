import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

abstract class WalletLocalDatasource {
  Future<void> init();
  Future<void> addWaletLocal(WalletModel wallet);
  Future<WalletModel?> getWallet(int id);
  Future<List<WalletModel>> myWallets();
  Future<void> clearWallets();
}
