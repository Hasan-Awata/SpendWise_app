import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

abstract class WalletRepository {
  Future<List<WalletModel>> getMyWallets();
  Future<void> addWallet(WalletModel wallet);
  Future<WalletModel?> getWalletById(int id);
}
