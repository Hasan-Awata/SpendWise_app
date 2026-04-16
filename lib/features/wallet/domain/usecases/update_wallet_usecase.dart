import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';

import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

class UpdateWalletUseCase {
  final WalletRepository repository;
  UpdateWalletUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int walletId, WalletModel wallet) async {
    return await repository.updateWallet(wallet);
  }
}
