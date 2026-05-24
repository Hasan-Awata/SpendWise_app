// // تعليق: حالة استخدام لجلب جميع المحافظ من المستودع
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class GetMyWalletsUseCase {
  final WalletRepository repository;
  GetMyWalletsUseCase(this.repository);

  Future<Either<Failure, List<WalletEntity>>> call() async {
    return await repository.getMyWallets();
  }
}
