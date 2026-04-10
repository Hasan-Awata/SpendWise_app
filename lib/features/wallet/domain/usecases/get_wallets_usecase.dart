// // تعليق: حالة استخدام لجلب جميع المحافظ من المستودع
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

class GetWalletsUseCase {
  final WalletRepository repository;
  GetWalletsUseCase(this.repository);

  Future<List<WalletModel>> call() async => await repository.getMyWallets();
}
