// // تعليق: حالة استخدام لجلب جميع المحافظ من المستودع
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

class GetMyWalletsUseCase {
  final WalletRepository repository;
  GetMyWalletsUseCase(this.repository);

  Future<Either<Failure, PagedResponse<WalletModel>>> call(
    PageRequest page,
  ) async {
    return await repository.getMyWallets(page);
  }
}
