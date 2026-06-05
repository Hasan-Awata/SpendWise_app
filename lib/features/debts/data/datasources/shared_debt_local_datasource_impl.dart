import 'package:isar/isar.dart';
import 'package:spendwise/features/debts/data/datasources/shared_debt_local_datasource.dart';
import 'package:spendwise/features/debts/data/models/shared_debt_model.dart';

class SharedDebtLocalDataSourceImpl implements SharedDebtLocalDataSource {
  @override
  final Isar isar;

  SharedDebtLocalDataSourceImpl(this.isar);

  // ========================= GET =========================

  @override
  Future<List<SharedDebtModel>> getDebts() async {
    try {
      return await isar.sharedDebtModels
          .where()
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      print("❌ Error fetching debts from Isar: $e");
      return [];
    }
  }

  @override
  Future<SharedDebtModel?> getDebt(String localId) async {
    return isar.sharedDebtModels
        .filter()
        .localIdEqualTo(localId)
        .findFirstSync();
  }

  @override
  Future<SharedDebtModel?> getDebtByIsarId(int? isarId) async {
    if (isarId == null) return null;

    return isar.sharedDebtModels.filter().isarIdEqualTo(isarId).findFirstSync();
  }

  @override
  SharedDebtModel? getDebtByServerId(int? debtId) {
    if (debtId == null) return null;

    return isar.sharedDebtModels.filter().debtIdEqualTo(debtId).findFirstSync();
  }

  // ========================= ADD / SAVE =========================

  @override
  Future<void> addDebt(SharedDebtModel debt) async {
    try {
      await isar.writeTxn(() async {
        await isar.sharedDebtModels.put(debt);
      });

      print("✅ Debt added locally: ${debt.title}");
    } catch (e) {
      print("❌ Error adding debt to Isar: $e");
      rethrow;
    }
  }

  @override
  Future<void> saveDebts(List<SharedDebtModel> debts) async {
    try {
      await isar.writeTxn(() async {
        await isar.sharedDebtModels.putAll(debts);
      });
    } catch (e) {
      print("❌ Error bulk saving debts to Isar: $e");
      rethrow;
    }
  }

  // ========================= UPDATE =========================

  @override
  Future<void> updateDebt(SharedDebtModel debt) async {
    try {
      await isar.writeTxn(() async {
        await isar.sharedDebtModels.put(debt);
      });

      print("✅ Debt updated locally: ${debt.title}");
    } catch (e) {
      print("❌ Error updating debt in Isar: $e");
      rethrow;
    }
  }

  // ========================= DELETE =========================

  @override
  Future<void> deleteDebt(SharedDebtModel debt) async {
    try {
      await isar.writeTxn(() async {
        await isar.sharedDebtModels.delete(debt.isarId);
      });

      print("✅ Debt deleted locally: ${debt.title}");
    } catch (e) {
      print("❌ Error deleting debt from Isar: $e");
      rethrow;
    }
  }

  // ========================= EXISTS =========================

  @override
  Future<bool> checkIfDebtExists(String localId) async {
    final count = await isar.sharedDebtModels
        .filter()
        .localIdEqualTo(localId)
        .count();

    return count > 0;
  }

  @override
  Future<bool> checkIfDebtExistsById(int? debtId) async {
    final count = await isar.sharedDebtModels
        .filter()
        .debtIdEqualTo(debtId)
        .count();

    return count > 0;
  }

  // ========================= REMOTE SYNC =========================

  @override
  Future<void> saveOrUpdateRemoteDebt(SharedDebtModel remoteDebt) async {
    await isar.writeTxn(() async {
      final existing = await isar.sharedDebtModels
          .filter()
          .debtIdEqualTo(remoteDebt.debtId)
          .findFirst();

      if (existing != null) {
        remoteDebt.isarId = existing.isarId;
        remoteDebt.localId = existing.localId;
        remoteDebt.isSynced = true;

        await isar.sharedDebtModels.put(remoteDebt);
      } else {
        remoteDebt.isSynced = true;

        await isar.sharedDebtModels.put(remoteDebt);
      }
    });
  }

  // ========================= CLEAR =========================

  @override
  Future<void> clear() async {
    try {
      await isar.writeTxn(() async {
        await isar.sharedDebtModels.clear();
      });

      print("🧹 SharedDebt local storage cleared");
    } catch (e) {
      print("❌ Error clearing SharedDebt storage: $e");
    }
  }
}
