// // تعليق: حالة استخدام لجلب جميع المحافظ من المستودع
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

class AddWalletUseCase {
  final WalletRepository repository;
  AddWalletUseCase(this.repository);

  Future<Either<Failure, String?>> call(WalletModel wallet) async {
    return await repository.addWallet(wallet);
  }
}
