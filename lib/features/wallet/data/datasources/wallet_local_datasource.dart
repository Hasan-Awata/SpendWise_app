import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

abstract class WalletLocalDatasource {
  Future<void> addWalletLocal(WalletModel wallet);

  WalletModel? getWallet(String localId);

  WalletModel? getWalletByIsarId(int isarId);

  Future<List<WalletModel>> myWallets();

  Future<void> deleteWallet(WalletModel wallet);

  Future<void> updateWallet(WalletModel wallet);

  Future<void> saveOrUpdateRemoteWallet(WalletModel remoteWallet);

  Future<void> clearWallets();
  WalletModel? getRegularWallet(int currencyId);
  WalletModel? getSavingsWallet(int currencyId);
  Future<void> upsertWallet(WalletModel wallet);
  Future<void> decreaseBalanceTransaction(int currencyId, double amount);
  Future<void> increaseBalanceTransaction(
    int currencyId,
    double amountFromRegular,
    double amountFromSavings,
  );
}
