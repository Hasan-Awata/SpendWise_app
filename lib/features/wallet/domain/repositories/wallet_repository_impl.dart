import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
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
  Future<Either<Failure, String?>> addWallet(WalletModel wallet) async {
    final network = NetworkService();
    return await network.saveLocalAndSync<String?>(
      localSave: () async {
        await localDatasource.addWaletLocal(wallet);
      },
      remoteSave: () async {
        final result = await remoteDatasource.addWalet(wallet);

        if (result == null) {
          throw Exception("Remote addWallet returned null");
        }

        return "تم الحفظ بنجاح";
      },
      onSyncSuccess: (serverId) async {
        wallet.isSynced = true;
        await localDatasource.updateWallet(wallet);
      },
      localResult: "تم الحفظ محلياً",
    );
  }

  @override
  Future<Either<Failure, PagedResponse<WalletModel>>> getMyWallets(
    PageRequest page,
  ) async {
    try {
      final remoteResponse = await remoteDatasource
          .getMyWallet(page)
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => throw SocketException("Timeout"),
          );

      _safeRemoteCall(() async {
        await Future.wait(
          remoteResponse.data.map((model) async {
            model.isSynced = true;
            await localDatasource.updateWallet(model);
          }),
        );
      });

      return Right(remoteResponse);
    } catch (e) {
      return await _getLocalPagedWallet(page);
    }
  }

  @override
  Future<Either<Failure, Unit>> updateWallet(WalletModel wallet) async {
    try {
      wallet.isSynced = false;
      await localDatasource.updateWallet(wallet);

      _safeRemoteCall(() async {
        final remote = await remoteDatasource.updateWallet(wallet);
        if (remote != null) {
          remote.isSynced = true;
          await localDatasource.updateWallet(remote);
        }
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل التحديث المحلي"));
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
      return Left(CacheFailure("فشل الحفظ المحلي"));
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
            if (wallet.walletId != null && wallet.walletId != -1) {
              await remoteDatasource.deleteWallet(wallet);
            }
            await localDatasource.deleteWallet(wallet);
            continue;
          }

          if (wallet.walletId != null && wallet.walletId != -1) {
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

  Future<Either<Failure, PagedResponse<WalletModel>>> _getLocalPagedWallet(
    PageRequest page,
  ) async {
    try {
      final all = await localDatasource.myWallets();
      final filtered = all
          .where((w) => w.localId != "REMOVE")
          .toList()
          .reversed
          .toList();

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
      return Left(CacheFailure("خطأ في معالجة البيانات المحلية"));
    }
  }

  Future<void> _safeRemoteCall(Future<dynamic> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<Either<Failure, List<WalletModel>>> getAllWalletsLocal() async {
    try {
      final wallets = await localDatasource.myWallets();
      return Right(wallets.where((w) => w.localId != "REMOVE").toList());
    } catch (e) {
      return Left(CacheFailure("فشل الوصول للمحفظة"));
    }
  }
}
