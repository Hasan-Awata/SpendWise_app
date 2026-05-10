import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class DeleteWalletUseCase {
  final WalletRepository repository;
  DeleteWalletUseCase(this.repository);

  Future<Either<Failure, Unit>> call(WalletEntity wallet) async {
    return await repository.deleteWallet(wallet);
  }
}
