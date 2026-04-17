import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

// // تعليق: مستودع المحافظ المطور - يتبنى ميزة الترتيب العكسي للأحدث أولاً مع الحفاظ على منطق المزامنة القوي
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDatasource remoteDatasource;
  final WalletLocalDatasource localDatasource;

  WalletRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, String?>> addWallet(WalletModel wallet) async {
    try {
      wallet.isSynced = false;
      await localDatasource.addWaletLocal(wallet);
      try {
        final newWalletFromServer = await remoteDatasource.addWalet(wallet);
        print("محفظ ة     ${newWalletFromServer.toString()}");
        if (newWalletFromServer != null) {
          newWalletFromServer.isSynced = true;
          await localDatasource.addWaletLocal(newWalletFromServer);
          return const Right("تمت العملية بنجاح");
        }
        return const Right("تم الحفظ محلياً");
      } catch (e) {
        return const Right("تم الحفظ محلياً");
      }
    } catch (e) {
      return Left(CacheFailure("فشل الحفظ المحلي"));
    }
  }

  @override
  Future<Either<Failure, PagedResponse<WalletModel>>> getMyWallets(
    PageRequest page,
  ) async {
    try {
      final remoteResponse = await remoteDatasource.getMyWallet(page);
      for (var model in remoteResponse.data) {
        model.isSynced = true;
        await localDatasource.addWaletLocal(model);
      }
      return Right(remoteResponse);
    } catch (e) {
      _safeRemoteCall(() => syncPendingWallets());
      return await _getLocalPagedWallet(page);
    }
  }

  Future<Either<Failure, PagedResponse<WalletModel>>> _getLocalPagedWallet(
    PageRequest page,
  ) async {
    try {
      final all = await localDatasource.myWallets();

      // ميزة Wallet: فلترة المحذوفات
      final filtered = all.where((w) => w.localId != "REMOVE").toList();

      // ميزة Tag: الترتيب للأحدث أولاً
      final reversedAll = filtered.reversed.toList();

      final start = (page.pageNumber - 1) * page.pageSize;
      final totalPages = (reversedAll.length / page.pageSize).ceil();

      if (start >= reversedAll.length) {
        return Right(
          PagedResponse(
            data: [],
            totalRecords: reversedAll.length,
            pageNumber: page.pageNumber,
            pageSize: page.pageSize,
            totalPages: totalPages,
          ),
        );
      }

      final end = start + page.pageSize;
      final sliced = reversedAll.sublist(
        start,
        end > reversedAll.length ? reversedAll.length : end,
      );

      return Right(
        PagedResponse(
          data: sliced,
          totalRecords: reversedAll.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في معالجة البيانات المحلية"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWallet(WalletModel wallet) async {
    try {
      wallet.localId = "REMOVE";
      wallet.isSynced = false;
      await localDatasource.updateWallet(wallet);

      _safeRemoteCall(() async {
        if (wallet.walletId != null && wallet.walletId! > 0) {
          await remoteDatasource.deleteWallet(wallet);
        }
        await localDatasource.deleteWallet(wallet);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل عملية الحذف"));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateWallet(WalletModel wallet) async {
    try {
      wallet.isSynced = false;
      await localDatasource.updateWallet(wallet);
      _safeRemoteCall(() async {
        await remoteDatasource.updateWallet(wallet);
        wallet.isSynced = true;
        await localDatasource.updateWallet(wallet);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل التحديث المحلي"));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingWallets() async {
    try {
      final allLocal = await localDatasource.myWallets();
      final pending = allLocal
          .where((i) => i.isSynced != true || i.localId == "REMOVE")
          .toList();

      for (var wallet in pending) {
        try {
          if (wallet.localId == "REMOVE") {
            if (wallet.walletId != null)
              await remoteDatasource.deleteWallet(wallet);
            await localDatasource.deleteWallet(wallet);
            continue;
          }
          if (wallet.walletId != null) {
            final remote = await remoteDatasource.updateWallet(wallet);
            if (remote != null) {
              remote.isSynced = true;
              await localDatasource.updateWallet(remote);
            }
          } else {
            final remote = await remoteDatasource.addWalet(wallet);
            if (remote != null) {
              remote.isSynced = true;
              await localDatasource.updateWallet(remote);
            }
          }
        } catch (e) {
          continue;
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل محرك المزامنة"));
    }
  }

  Future<void> _safeRemoteCall(Future<dynamic> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint("⚠️ مزامنة صامتة فشلت: $e");
    }
  }

  @override
  Future<Either<Failure, List<WalletModel>>> getAllWalletsLocal() async {
    try {
      final wallets = await localDatasource.myWallets();
      return Right(wallets.where((w) => w.localId != "REMOVE").toList());
    } catch (e) {
      return Left(CacheFailure("لا يمكن الوصول للمحافظ محلياً"));
    }
  }
}
