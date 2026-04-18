import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
  Future<Either<Failure, String?>> addWallet(WalletModel wallet) async {
    try {
      print("🚀 Starting addWallet: ${wallet.localId}");
      wallet.isSynced = false;
      await localDatasource.addWaletLocal(wallet);

      try {
        final newWalletFromServer = await remoteDatasource.addWalet(wallet);

        if (newWalletFromServer != null) {
          print("✅ Server Add Success: ${newWalletFromServer.walletId}");
          newWalletFromServer.isSynced = true;
          await localDatasource.addWaletLocal(newWalletFromServer);
          return const Right("تمت المزامنة والحفظ بنجاح");
        }
        return const Right("تم الحفظ محلياً");
      } catch (remoteError) {
        print("⚠️ Server Add Failed: $remoteError");
        return const Right("تم الحفظ محلياً فقط");
      }
    } catch (localError) {
      print("❌ Local Add Critical Error: $localError");
      return Left(CacheFailure("فشل الحفظ المحلي"));
    }
  }

  @override
  Future<Either<Failure, PagedResponse<WalletModel>>> getMyWallets(
    PageRequest page,
  ) async {
    try {
      print("📡 Fetching Wallets from Server - Page: ${page.pageNumber}");
      final remoteResponse = await remoteDatasource.getMyWallet(page);

      for (var model in remoteResponse.data) {
        model.isSynced = true;
        await localDatasource.addWaletLocal(model);
      }
      return Right(remoteResponse);
    } catch (e) {
      print("🌐 Connection Issue: Switching to Local Storage. Error: $e");
      _safeRemoteCall(() => syncPendingWallets());
      return await _getLocalPagedWallet(page);
    }
  }

  @override
  Future<Either<Failure, Unit>> updateWallet(WalletModel wallet) async {
    try {
      print("🔄 Updating Wallet Locally: ${wallet.walletId}");
      wallet.isSynced = false;
      await localDatasource.updateWallet(wallet);

      _safeRemoteCall(() async {
        final remote = await remoteDatasource.updateWallet(wallet);
        if (remote != null) {
          print("✅ Server Update Sync Done");
          remote.isSynced = true;
          await localDatasource.updateWallet(remote);
        }
      });
      return const Right(unit);
    } catch (e) {
      print("❌ Local Update Error: $e");
      return Left(CacheFailure("فشل التحديث المحلي"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWallet(WalletModel wallet) async {
    try {
      print("🗑️ Marking Wallet for Removal: ${wallet.walletId}");
      wallet.localId = "REMOVE";
      wallet.isSynced = false;
      await localDatasource.updateWallet(wallet);

      _safeRemoteCall(() async {
        if (wallet.walletId != null && wallet.walletId! > 0) {
          await remoteDatasource.deleteWallet(wallet);
          print("✅ Server Delete Done");
        }
        await localDatasource.deleteWallet(wallet);
      });
      return const Right(unit);
    } catch (e) {
      print("❌ Local Delete Error: $e");
      return Left(CacheFailure("فشل الحذف المحلي"));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingWallets() async {
    try {
      final allLocal = await localDatasource.myWallets();
      final pending = allLocal
          .where((i) => i.isSynced != true || i.localId == "REMOVE")
          .toList();

      print("🔄 Sync Engine: Found ${pending.length} pending items");

      for (var wallet in pending) {
        try {
          if (wallet.localId == "REMOVE") {
            if (wallet.walletId != null)
              await remoteDatasource.deleteWallet(wallet);
            await localDatasource.deleteWallet(wallet);
            print("📤 Synced: DELETED ${wallet.walletId}");
            continue;
          }

          if (wallet.walletId != null) {
            final remote = await remoteDatasource.updateWallet(wallet);
            if (remote != null) {
              remote.isSynced = true;
              await localDatasource.updateWallet(remote);
              print("📤 Synced: UPDATED ${wallet.walletId}");
            }
          } else {
            final remote = await remoteDatasource.addWalet(wallet);
            if (remote != null) {
              remote.isSynced = true;
              await localDatasource.updateWallet(remote);
              print("📤 Synced: CREATED ${remote.walletId}");
            }
          }
        } catch (e) {
          print("⚠️ Sync Error for item: $e");
          continue;
        }
      }
      return const Right(unit);
    } catch (e) {
      print("❌ Global Sync Engine Failure: $e");
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

      print("📦 Local Data Loaded: ${sliced.length} items");
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
      debugPrint("📢 Background Sync Silent Info: $e");
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
