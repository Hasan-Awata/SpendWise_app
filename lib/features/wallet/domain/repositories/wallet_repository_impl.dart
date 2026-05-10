import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/currency_repository.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDatasource remote;
  final WalletLocalDatasource local;
  final CurrencyRepository currencyRepository;
  final NetworkService network;

  WalletRepositoryImpl({
    required this.remote,
    required this.local,
    required this.currencyRepository,
    required this.network,
  });

  // =========================
  // ADD
  // =========================
  @override
  Future<Either<Failure, String>> addWallet(WalletEntity wallet) async {
    try {
      final exists = await local.checkIfWalletExists(wallet.localId);
      if (exists) {
        return Left(CacheFailure("Wallet already exists"));
      }

      final model = WalletModel.fromEntity(wallet)
        ..isSynced = false
        ..isDeleted = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await local.addWalletLocal(model);

      _trySync(model);

      return const Right("Saved locally");
    } catch (_) {
      return Left(CacheFailure("Add failed"));
    }
  }

  // =========================
  // UPDATE
  // =========================
  @override
  Future<Either<Failure, Unit>> updateWallet(WalletEntity wallet) async {
    try {
      final localWallet = local.getWallet(wallet.localId);
      if (localWallet == null) {
        return Left(CacheFailure("Not found"));
      }

      localWallet
        ..balance = wallet.balance
        ..currencyId = wallet.currencyId
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await local.updateWallet(localWallet);

      _trySync(localWallet);

      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure("Update failed"));
    }
  }

  // =========================
  // DELETE
  // =========================
  @override
  Future<Either<Failure, Unit>> deleteWallet(WalletEntity wallet) async {
    try {
      final localWallet = local.getWallet(wallet.localId);
      if (localWallet == null) {
        return Left(CacheFailure("Not found"));
      }

      localWallet
        ..isDeleted = true
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await local.updateWallet(localWallet);

      _trySync(localWallet);

      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure("Delete failed"));
    }
  }

  @override
  Future<Either<Failure, PagedResponse<WalletEntity>>> getMyWallets(
    PageRequest page,
  ) async {
    try {
      final localData = await local.myWallets();

      if (await network.isConnected) {
        _performBackgroundSync(localData);
      }

      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );

      final start = (page.pageNumber - 1) * page.pageSize;
      final end = (start + page.pageSize).clamp(0, filtered.length);
      final slice = start >= filtered.length
          ? <WalletModel>[]
          : filtered.sublist(start, end);

      final entities = slice.map((w) {
        w.currency = currencyRepository.getById(w.currencyId);
        return w.toEntity();
      }).toList();

      return Right(
        PagedResponse(
          data: entities,
          totalRecords: filtered.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: (filtered.length / page.pageSize).ceil(),
        ),
      );
    } catch (_) {
      return Left(CacheFailure("Fetch failed"));
    }
  }

  // دالة مزامنة لا تعطل التدفق الأساسي
  void _performBackgroundSync(List<WalletModel> items) {
    for (final item in items) {
      if (!item.isSynced) {
        // تنفيذ المزامنة بشكل منفصل
        _syncItemSafe(item).catchError((e) => debugPrint("Sync Error: $e"));
      }
    }
  }

  // =========================
  // SAFE SYNC ENTRY
  // =========================
  Future<void> _trySync(WalletModel item) async {
    if (!await network.isConnected) return;
    await _syncItemSafe(item);
  }

  // =========================
  // CORE SAFE SYNC
  // =========================
  Future<void> _syncItemSafe(WalletModel item) async {
    try {
      if (item.isDeleted) {
        if (item.walletId != null) {
          await remote.deleteWallet(item);
        }
        await local.deleteWallet(item);
        return;
      }

      if (item.walletId == null || item.walletId == -1) {
        final res = await remote.addWalet(item);
        if (res != null) {
          item.walletId = res.walletId;
        }
      } else {
        await remote.updateWallet(item);
      }

      item
        ..isSynced = true
        ..syncAttempts = 0;

      await local.updateWallet(item);
    } catch (_) {
      item
        ..syncAttempts += 1
        ..isSynced = false;

      if (item.syncAttempts > 5) {
        item.isSynced = true; // stop retry spam
      }

      await local.updateWallet(item);
    }
  }

  // =========================
  // LOCAL ONLY
  // =========================
  @override
  Future<Either<Failure, List<WalletEntity>>> getAllWalletsLocal() async {
    try {
      final models = await local.myWallets();

      final active = models.where((m) => !m.isDeleted).map((w) {
        w.currency = currencyRepository.getById(w.currencyId);
        return w.toEntity();
      }).toList();

      return Right(active);
    } catch (_) {
      return Left(CacheFailure("Local fetch failed"));
    }
  }
}
