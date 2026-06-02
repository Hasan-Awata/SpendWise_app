// lib/features/wallet/data/repositories/wallet_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
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
  final NetworkService networkService = Get.find();

  WalletRepositoryImpl({
    required this.remote,
    required this.local,
    required this.currencyRepository,
    required this.syncQueueRepository,
  });

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
  // ADD
  // =========================
  @override
  Future<Either<Failure, WalletEntity>> addWallet(WalletEntity wallet) async {
    try {
      final isOnline = networkService.isOnline.value;

      final model = WalletModel.fromEntity(wallet)
        ..isSynced = false
        ..isDeleted = false
        ..walletId = null
        ..balance = 0;

      // 1. حفظ محلي
      await local.addWalletLocal(model);

      WalletModel finalModel = model;

      // 2. مزامنة إذا أونلاين
      if (isOnline) {
        try {
          final remoteWallet = await remote.addWalet(model);

          if (remoteWallet != null) {
            model.walletId = remoteWallet.walletId;
            model.isSynced = true;

            await local.updateWallet(model);

            finalModel = model;
          }
        } catch (e) {
          await _addToQueue(model, SyncAction.create);
        }
      } else {
        await _addToQueue(model, SyncAction.create);
      }

      // ✔️ أهم تعديل هنا
      final resultEntity = finalModel.toEntity();

      final amount = wallet.balance;
      print("AMOUNT IS IS ---->$amount");
      final income = IncomeEntity(
        userId: wallet.userId,
        wallet: wallet,
        walletId: resultEntity.walletId ?? -1, // ✔️ مهم جداً
        description: "DEFAULT INCOME",
        date: DateTime.now(),
        title: "DEFAULT INCOME",

        amount: amount,
      );

      await Get.find<IncomeRepository>().addIncome(income);

      return Right(resultEntity);
    } catch (e) {
      return Left(CacheFailure("فشل الحفظ: $e"));
    }
  }

  // =========================
  // UPDATE
  // =========================
  @override
  Future<Either<Failure, String>> updateWallet(WalletEntity wallet) async {
    try {
      final isOnline = networkService.isOnline.value;

      final localWallet = local.getWallet(wallet.localId);

      if (localWallet == null) {
        return const Right("غير موجود");
      }

      localWallet
        ..balance = wallet.balance
        ..currencyId = wallet.currencyId;

      if (isOnline) {
        try {
          await remote.updateWallet(localWallet);
          localWallet.isSynced = true;
        } catch (e) {
          await _addToQueue(localWallet, SyncAction.update);
        }
      } else {
        await _addToQueue(localWallet, SyncAction.update);
      }

      await local.updateWallet(localWallet);

      return const Right("تم التحديث");
    } catch (e) {
      return Left(CacheFailure("فشل التحديث: $e"));
    }
  }

  // =========================
  // DELETE
  // =========================
  @override
  Future<Either<Failure, String>> deleteWallet(WalletEntity wallet) async {
    try {
      final isOnline = networkService.isOnline.value;

      final localWallet = local.getWallet(wallet.localId);

      if (localWallet == null) {
        return const Right("غير موجود");
      }

      // =========================
      // حفظ الحالة قبل التعديل (Rollback backup)
      // =========================
      final backupWallet = localWallet.copyWith();

      // Soft delete محلياً
      localWallet.isDeleted = true;
      await local.updateWallet(localWallet);

      if (isOnline) {
        try {
          await remote.deleteWallet(localWallet);

          // نجاح → حذف نهائي محلي
          await local.deleteWallet(localWallet);
        } catch (e) {
          // =========================
          // ❌ ROLLBACK
          // =========================

          backupWallet.isDeleted = false;
          await local.updateWallet(backupWallet);

          return Left(CacheFailure("فشل الحذف من السيرفر وتم إلغاء العملية"));
        }
      } else {
        await _addToQueue(localWallet, SyncAction.delete);
        await local.updateWallet(localWallet);
      }

      return const Right("تم الحذف");
    } catch (e) {
      return Left(CacheFailure("فشل الحذف: $e"));
    }
  }
  // =========================
  // BALANCE OPERATIONS
  // =========================

  @override
  Future<Either<Failure, String>> decreaseBalance({
    required int walletId,
    required double amount,
  }) async {
    try {
      // تنفيذ خصم الرصيد (المنطق داخل Datasource يقوم بالتوزيع بين الجارية والادخار)
      await local.decreaseBalanceTransaction(walletId, amount);
      return const Right("تم خصم الرصيد بنجاح");
    } catch (e) {
      return Left(CacheFailure("فشل عملية الخصم: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, String>> increaseBalance({
    required int walletId,
    required double amountFromRegular,
    required double amountFromSavings,
  }) async {
    try {
      // تنفيذ إعادة الرصيد (Rollback) لكل محفظة بناءً على القيم التي خُصمت منها
      await local.increaseBalanceTransaction(
        walletId,
        amountFromRegular,
        amountFromSavings,
      );
      return const Right("تم استرجاع الرصيد بنجاح");
    } catch (e) {
      return Left(CacheFailure("فشل استرجاع الرصيد: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, double>> getWalletBalance({
    required int currencyId,
  }) async {
    try {
      // جلب كل المحافظ من مصدر البيانات المحلي
      final allWallets = await local.myWallets();

      // حساب مجموع الأرصدة للمحافظ التي لها نفس العملة
      double total = allWallets
          .where((w) => w.currencyId == currencyId)
          .fold(0.0, (sum, w) => sum + w.balance);

      return Right(total);
    } catch (e) {
      return Left(CacheFailure("خطأ في حساب رصيد العملة: $e"));
    }
  }

  // =========================
  // QUEUE HELPER
  // =========================
  Future<void> _addToQueue(WalletModel model, SyncAction action) async {
    await syncQueueRepository.addToQueue(
      SyncQueueModel(
        id: const Uuid().v4(),
        localId: model.localId,
        action: action,
        table: "wallet",
        createdAt: DateTime.now(),
        isarId: model.isarId,
      ),
    );
  }
}
