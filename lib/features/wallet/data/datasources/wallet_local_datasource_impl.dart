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
  Future<bool> checkIfWalletExists(String localId) async {
    // استخدام query مباشر للبحث عن الـ localId فقط دون جلب كافة البيانات للذاكرة
    final count = await isar.walletModels
        .filter()
        .localIdEqualTo(localId)
        .count();

    return count > 0;
  }

  @override
  Future<bool> checkIfWalletExistsByWalletId(int? id) async {
    // استخدام query مباشر للبحث عن الـ localId فقط دون جلب كافة البيانات للذاكرة
    final count = await isar.walletModels.filter().walletIdEqualTo(id).count();

    return count > 0;
  }

  @override
  WalletModel? getWalletByServerId(int? walletId) {
    if (walletId == null) return null;

    return isar.walletModels.filter().walletIdEqualTo(walletId).findFirstSync();
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
  WalletModel? getWalletByIsarId(int? isarId) {
    if (isarId == null) return null;

    return isar.walletModels.filter().isarIdEqualTo(isarId).findFirstSync();
  }
}
