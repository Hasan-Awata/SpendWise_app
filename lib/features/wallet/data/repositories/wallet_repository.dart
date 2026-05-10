// Abstract class for Wallet Repository following Clean Architecture patterns
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, String?>> addWallet(WalletEntity wallet);

  Future<Either<Failure, PagedResponse<WalletEntity>>> getMyWallets(
    PageRequest page,
  );

  Future<Either<Failure, Unit>> updateWallet(WalletEntity wallet);

  Future<Either<Failure, Unit>> deleteWallet(WalletEntity wallet);

  Future<Either<Failure, List<WalletEntity>>> getAllWalletsLocal();
}
