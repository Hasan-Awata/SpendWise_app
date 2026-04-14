// // تعليق: تنفيذ المستودع مع تطبيق Dartz بشكل صارم لمعالجة حالات الفشل (Left) والنجاح (Right)
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDatasource remoteDatasource;
  final WalletLocalDatasource localDatasource;

  WalletRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, Unit>> addWallet(WalletModel wallet) async {
    try {
      await remoteDatasource.addWalet(wallet);
      return const Right(unit); // // تعليق: حالة النجاح تعيد Right مع Unit
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.message ?? "Server Error"),
      ); // // تعليق: حالة الفشل تعيد Left مع Failure
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PagedResponse<WalletModel>>> getMyWallets(
    PageRequest page,
  ) async {
    try {
      final remoteWallets = await remoteDatasource.getMyWallet(page);
      return Right(remoteWallets); // // تعليق: إعادة البيانات المغلفة بـ Right
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? "Server Error"));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateWallet(
    int walletId,
    WalletModel wallet,
  ) async {
    try {
      await remoteDatasource.updateWallet(walletId, wallet);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? "Server Error"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWallet(int walletId) async {
    try {
      await remoteDatasource.deleteWallet(walletId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? "Server Error"));
    }
  }

  @override
  Future<Either<Failure, List<WalletModel>>> getAllWalletsLocal() async {
    try {
      final localData = await localDatasource.myWallets();
      return Right(localData);
    } catch (e) {
      return Left(
        CacheFailure("خطأ في جلب المحافظ"),
      ); // // تعليق: فشل في جلب البيانات من الكاش المحلي
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingWallets() async {
    try {
      // منطق المزامنة هنا
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure("Sync Failed"));
    }
  }
}
