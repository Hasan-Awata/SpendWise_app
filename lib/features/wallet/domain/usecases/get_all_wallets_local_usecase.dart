// // تعليق: UseCase مخصص لجلب المحافظ من التخزين المحلي فقط دون الحاجة للسيرفر
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class GetAllWalletsLocalUseCase {
  final WalletRepository repository;

  GetAllWalletsLocalUseCase(this.repository);

  Future<Either<Failure, List<WalletEntity>>> call() async {
    return await repository.getAllWalletsLocal();
  }
}
