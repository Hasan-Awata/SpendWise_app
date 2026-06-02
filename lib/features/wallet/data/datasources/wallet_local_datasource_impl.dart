import 'package:isar/isar.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class WalletLocalDatasourceImpl implements WalletLocalDatasource {
  final Isar isar;

  WalletLocalDatasourceImpl(this.isar);

  @override
  Future<List<WalletModel>> myWallets() async {
    return await isar.walletModels.where().findAll();
  }

  @override
  Future<void> addWalletLocal(WalletModel model) async {
    await isar.writeTxn(() async {
      await isar.walletModels.put(model);
    });
  }

  @override
  Future<void> deleteWallet(WalletModel wallet) async {
    await isar.writeTxn(() async {
      await isar.walletModels
          .filter()
          .localIdEqualTo(wallet.localId)
          .deleteAll();
    });
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    await isar.writeTxn(() async {
      await isar.walletModels.put(wallet);
    });
  }

  @override
  Future<void> clearWallets() async {
    await isar.writeTxn(() => isar.walletModels.clear());
  }

  @override
  WalletModel? getWallet(String localId) {
    return isar.walletModels.filter().localIdEqualTo(localId).findFirstSync();
  }

  @override
  WalletModel? getWalletByIsarId(int? isarId) {
    if (isarId == null) return null;

    return isar.walletModels.filter().isarIdEqualTo(isarId).findFirstSync();
  }

  @override
  Future<void> saveOrUpdateRemoteWallet(WalletModel remoteWallet) async {
    await isar.writeTxn(() async {
      final existing = await isar.walletModels
          .filter()
          .walletIdEqualTo(remoteWallet.walletId)
          .findFirst();

      if (existing != null) {
        existing
          ..balance = remoteWallet.balance
          ..currencyId = remoteWallet.currencyId
          ..isSynced = true
          ..updatedAt = remoteWallet.updatedAt;

        await isar.walletModels.put(existing);
      } else {
        remoteWallet
          ..isSynced = true
          ..isDeleted = false;

        await isar.walletModels.put(remoteWallet);
      }
    });
  }

  @override
  WalletModel? getRegularWallet(int currencyId) {
    // البحث عن المحفظة الجارية (بافتراض وجود حقل type في WalletModel)
    return isar.walletModels
        .filter()
        .currencyIdEqualTo(currencyId + 1)
        .isSavedEqualTo(false)
        .isDeletedEqualTo(false)
        .findFirstSync();
  }

  @override
  WalletModel? getSavingsWallet(int currencyId) {
    return isar.walletModels
        .filter()
        .currencyIdEqualTo(currencyId + 1)
        .isSavedEqualTo(true)
        .isDeletedEqualTo(false)
        .findFirstSync();
  }

  @override
  Future<void> upsertWallet(WalletModel wallet) async {
    await isar.writeTxn(() async {
      final existing = await isar.walletModels
          .filter()
          .localIdEqualTo(wallet.localId)
          .findFirst();

      if (existing != null) {
        wallet.isarId = existing.isarId;
      }

      await isar.walletModels.put(wallet);
    });
  }

  @override
  Future<void> decreaseBalanceTransaction(int walletId, double amount) async {
    // // ضمان ذرية العملية (Atomic Transaction) لمنع تضارب الأرصدة
    await isar.writeTxn(() async {
      final regular = await isar.walletModels
          .filter()
          .walletIdEqualTo(walletId)
          .isSavedEqualTo(false)
          .isDeletedEqualTo(false)
          .findFirst();

      final savings = await isar.walletModels
          .filter()
          .walletIdEqualTo(walletId)
          .isSavedEqualTo(true)
          .isDeletedEqualTo(false)
          .findFirst();

      if (regular == null) throw Exception("المحفظة الجارية غير موجودة");

      // 1. التحقق من الرصيد الكلي المتاح
      double totalAvailable = regular.balance + (savings?.balance ?? 0.0);
      if (totalAvailable < amount) {
        throw Exception("الرصيد الكلي غير كافٍ");
      }

      // 2. منطق توزيع السحب: أولوية للجارية، ثم الادخار
      double fromRegular = (regular.balance >= amount)
          ? amount
          : regular.balance;
      double fromSavings = amount - fromRegular;

      // 3. تطبيق الخصم الفعلي
      regular.balance -= fromRegular;
      regular.numberOfTransactions += 1;
      if (savings != null && fromSavings > 0) {
        savings.balance -= fromSavings;
        await isar.walletModels.put(savings);
      }

      await isar.walletModels.put(regular);
    });
  }

  @override
  Future<void> increaseBalanceTransaction(
    int walletId,
    double amountFromRegular,
    double amountFromSavings,
  ) async {
    // // دالة التراجع الدقيقة: تعيد المبالغ للمحفظة التي خرجت منها
    await isar.writeTxn(() async {
      final regular = await isar.walletModels
          .filter()
          .walletIdEqualTo(walletId)
          .isSavedEqualTo(false)
          .isDeletedEqualTo(false)
          .findFirst();

      final savings = await isar.walletModels
          .filter()
          .walletIdEqualTo(walletId)
          .isSavedEqualTo(true)
          .isDeletedEqualTo(false)
          .findFirst();

      if (regular == null) throw Exception("المحفظة الجارية غير موجودة");

      // إرجاع كل جزء إلى محفظته الأصلية
      regular.balance += amountFromRegular;
      regular.numberOfTransactions += 1;
      await isar.walletModels.put(regular);

      if (savings != null && amountFromSavings > 0) {
        savings.balance += amountFromSavings;
        await isar.walletModels.put(savings);
      }
    });
  }
}
