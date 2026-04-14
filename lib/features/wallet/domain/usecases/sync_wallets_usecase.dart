import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

class SyncWalletsUseCase {
  final WalletRepository repository;
  SyncWalletsUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.syncPendingWallets();
  }
}
