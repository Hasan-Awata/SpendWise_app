// // تعليق: UseCase مخصص لجلب المحافظ من التخزين المحلي فقط دون الحاجة للسيرفر
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

class GetAllWalletsLocalUseCase {
  final WalletRepository repository;

  GetAllWalletsLocalUseCase(this.repository);

  Future<Either<Failure, List<WalletModel>>> call() async {
    return await repository.getAllWalletsLocal();
  }
}
