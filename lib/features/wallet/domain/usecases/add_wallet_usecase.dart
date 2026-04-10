// // تعليق: حالة استخدام لجلب جميع المحافظ من المستودع
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

class AddWalletUseCase {
  final WalletRepository repository;
  AddWalletUseCase(this.repository);

  Future<void> call(WalletModel wallet) async =>
      await repository.addWallet(wallet);
}
