import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  /// إضافة محفظة
  /// ترجع رسالة توضح الحالة (محلي / تم المزامنة / خطأ)
  Future<Either<Failure, WalletEntity>> addWallet(WalletEntity wallet);

  /// جلب المحافظ
  Future<Either<Failure, List<WalletEntity>>> getMyWallets();

  /// تحديث محفظة
  Future<Either<Failure, String>> updateWallet(WalletEntity wallet);

  /// حذف محفظة
  Future<Either<Failure, String>> deleteWallet(WalletEntity wallet);
  Future<Either<Failure, String>> decreaseBalance({
    required int walletId,
    required double amount,
  });

  Future<Either<Failure, String>> increaseBalance({
    required int walletId,
    required double amountFromRegular,
    required double amountFromSavings,
  });
  Future<Either<Failure, double>> getWalletBalance({required int walletId});

  Future<Either<Failure, List<WalletEntity>>> getWalletsByCurrencyId(
    int currencyId,
  );
  Future<Either<Failure, WalletEntity>> getWalletById(int walletId);
}
