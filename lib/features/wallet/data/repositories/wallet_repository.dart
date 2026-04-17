// Abstract class for Wallet Repository following Clean Architecture patterns
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

abstract class WalletRepository {
  Future<Either<Failure, String?>> addWallet(WalletModel wallet);

  Future<Either<Failure, PagedResponse<WalletModel>>> getMyWallets(
    PageRequest page,
  );

  Future<Either<Failure, Unit>> updateWallet(WalletModel wallet);

  Future<Either<Failure, Unit>> deleteWallet(WalletModel wallet);

  Future<Either<Failure, List<WalletModel>>> getAllWalletsLocal();

  Future<Either<Failure, Unit>> syncPendingWallets();
}
