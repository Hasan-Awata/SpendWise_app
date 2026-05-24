import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/currency_repository.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDatasource remote;
  final WalletLocalDatasource local;
  final CurrencyRepository currencyRepository;
  final SyncQueueRepository syncQueueRepository;
  WalletRepositoryImpl({
    required this.remote,
    required this.local,
    required this.currencyRepository,
    required this.syncQueueRepository,
  });

  // =========================
  // GET LOCAL
  // =========================
  @override
  Future<Either<Failure, List<WalletEntity>>> getMyWallets() async {
    try {
      final networkService = Get.find<NetworkService>();
      final isOnline = networkService.isOnline.value;

      if (isOnline) {
        try {
          final remoteResponse = await remote.getMyWallets();

          if (remoteResponse != null) {
            await local.clearWallets();

            for (var remoteWallet in remoteResponse) {
              remoteWallet.isSynced = true;
              remoteWallet.isDeleted = false;
              await local.addWalletLocal(remoteWallet);
            }
          }
        } catch (remoteError) {
          if (kDebugMode) {
            print("⚠️ Failed to fetch wallets from remote: $remoteError");
          }
        }
      }

      final localData = await local.myWallets();

      final entities = localData.where((e) => !e.isDeleted).map((w) {
        w.currency = currencyRepository.getById(w.currencyId);
        return w.toEntity();
      }).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure("حدث خطأ أثناء جلب المحافظ: ${e.toString()}"));
    }
  }

  // =========================
  // ADD LOCAL ONLY
  // =========================
  @override
  Future<Either<Failure, String>> addWallet(WalletEntity wallet) async {
    try {
      final model = WalletModel.fromEntity(wallet)
        ..isSynced = false
        ..isDeleted = false
        ..walletId = null;

      await local.addWalletLocal(model);
      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: model.localId,
          action: SyncAction.create,
          table: "wallet",
          createdAt: DateTime.now(),
          isarId: model.isarId,
        ),
      );

      return const Right("تم الحفظ محلياً");
    } catch (_) {
      return Left(CacheFailure("فشل الحفظ"));
    }
  }

  // =========================
  // UPDATE LOCAL ONLY
  // =========================
  @override
  Future<Either<Failure, String>> updateWallet(WalletEntity wallet) async {
    try {
      final localWallet = local.getWallet(wallet.localId);

      if (localWallet == null) {
        return const Right("غير موجود");
      }

      localWallet
        ..balance = wallet.balance
        ..currencyId = wallet.currencyId
        ..isSynced = false;

      await local.updateWallet(localWallet);
      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: localWallet.localId,
          action: SyncAction.update,
          table: "wallet",
          createdAt: DateTime.now(),
          isarId: localWallet.isarId,
        ),
      );

      return const Right("تم التحديث محلياً");
    } catch (_) {
      return Left(CacheFailure("فشل التحديث"));
    }
  }

  // =========================
  // DELETE LOCAL ONLY
  // =========================
  @override
  Future<Either<Failure, String>> deleteWallet(WalletEntity wallet) async {
    try {
      final localWallet = local.getWallet(wallet.localId);

      if (localWallet == null) {
        return const Right("غير موجود");
      }

      localWallet
        ..isDeleted = true
        ..isSynced = false;

      await local.updateWallet(localWallet);
      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: localWallet.localId,
          action: SyncAction.delete,
          table: "wallet",
          createdAt: DateTime.now(),
          isarId: localWallet.isarId,
        ),
      );

      return const Right("تم الحذف محلياً");
    } catch (_) {
      return Left(CacheFailure("فشل الحذف"));
    }
  }
}
