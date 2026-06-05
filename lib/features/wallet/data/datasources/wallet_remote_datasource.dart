import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

abstract class WalletRemoteDatasource {
  Future<WalletModel?> addWalet(WalletModel wallet);
  Future<List<WalletModel>?> getMyWallets();

  Future<WalletModel?> updateWallet(WalletModel wallet);

  Future<bool> deleteWallet(WalletModel wallet);

  Future<WalletModel?> getWalletById(int walletId);
  Future<List<WalletModel>?> getWalletsByCurrencyId(int currencyId);
}
