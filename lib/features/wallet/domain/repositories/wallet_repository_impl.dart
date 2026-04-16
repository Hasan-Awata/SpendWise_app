import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDatasource remoteDatasource;
  final WalletLocalDatasource localDatasource;

  WalletRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, Unit>> addWallet(WalletEntity wallet) async {
    final model = wallet as WalletModel;
    try {
      model.isSynced = false;
      await localDatasource.addWaletLocal(model);

      _safeRemoteCall(() async {
        final walletServer = await remoteDatasource.addWalet(model);
        walletServer.isSynced = true;
        await localDatasource.updateWallet(walletServer);
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل الحفظ المحلي للمحفظة"));
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
      return Left(CacheFailure("فشل التحديث المحلي للمحفظة"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWallet(WalletModel wallet) async {
    try {
      wallet.localId = "REMOVE";
      wallet.isSynced = false;
      await localDatasource.updateWallet(wallet);

      _safeRemoteCall(() async {
        if (wallet.walletId != null && wallet.walletId != -1) {
          await remoteDatasource.deleteWallet(wallet);
        }
        await localDatasource.deleteWallet(wallet);
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل عملية الحذف محلياً"));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingWallets() async {
    try {
      final allLocal = await localDatasource.myWallets();
      final pending = allLocal
          .where((w) => !w.isSynced || w.localId == "REMOVE")
          .toList();

      for (var wallet in pending) {
        try {
          if (wallet.localId == "REMOVE") {
            if (wallet.walletId != null && wallet.walletId != -1) {
              await remoteDatasource.deleteWallet(wallet);
            }
            await localDatasource.deleteWallet(wallet);
            continue;
          }

          if (!wallet.isSynced) {
            if (wallet.walletId == null || wallet.walletId == -1) {
              final remote = await remoteDatasource.addWalet(wallet);
              remote.isSynced = true;
              await localDatasource.updateWallet(remote);
            } else {
              await remoteDatasource.updateWallet(wallet);
              wallet.isSynced = true;
              await localDatasource.updateWallet(wallet);
            }
          }
        } catch (_) {
          continue;
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure("فشل محرك مزامنة المحافظ"));
    }
  }

  Future<void> _safeRemoteCall(Future<dynamic> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint("Wallet Silent Sync Error: $e");
    }
  }

  Future<Either<Failure, PagedResponse<WalletModel>>> _getLocalPagedWallet(
    PageRequest page,
  ) async {
    try {
      final all = await localDatasource.myWallets();
      final filtered = all.where((w) => w.localId != "REMOVE").toList();

      final start = (page.pageNumber - 1) * page.pageSize;
      final totalPages = (filtered.length / page.pageSize).ceil();

      if (start >= filtered.length) {
        return Right(
          PagedResponse(
            data: [],
            totalRecords: filtered.length,
            pageNumber: page.pageNumber,
            pageSize: page.pageSize,
            totalPages: totalPages,
          ),
        );
      }

      final end = start + page.pageSize;
      final sliced = filtered.sublist(
        start,
        end > filtered.length ? filtered.length : end,
      );

      return Right(
        PagedResponse(
          data: sliced,
          totalRecords: filtered.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في معالجة كاش المحافظ"));
    }
  }

  @override
  Future<Either<Failure, List<WalletModel>>> getAllWalletsLocal() async {
    try {
      final wallets = await localDatasource.myWallets();
      final visibleWallets = wallets
          .where((w) => w.localId != "REMOVE")
          .toList();
      return Right(visibleWallets);
    } catch (e) {
      return Left(CacheFailure("لا يمكن الوصول للمحافظ محلياً"));
    }
  }
}
