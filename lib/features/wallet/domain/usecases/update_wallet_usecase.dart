import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class UpdateWalletUseCase {
  final WalletRepository repository;
  UpdateWalletUseCase(this.repository);

  Future<Either<Failure, String>> call(WalletEntity wallet) async {
    return await repository.updateWallet(wallet);
  }
}
