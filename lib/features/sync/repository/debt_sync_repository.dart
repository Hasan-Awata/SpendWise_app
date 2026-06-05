import 'package:spendwise/features/debts/data/datasources/shared_debt_local_datasource.dart';
import 'package:spendwise/features/debts/data/datasources/shared_debt_remote_datasource.dart';
import 'package:spendwise/features/debts/data/models/shared_debt_model.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

class SharedDebtSyncRepository implements SyncRepository<SharedDebtModel> {
  final SharedDebtLocalDataSource local;
  final SharedDebtRemoteDatasource remote;

  SharedDebtSyncRepository({required this.local, required this.remote});

  // =========================================================
  // CREATE SYNC
  // =========================================================
  @override
  Future<void> createByLocalId(int localId) async {
    final debt = await local.getDebtByIsarId(localId);
    if (debt == null) return;

    // 🔴 منع إعادة الإرسال إذا متزامن
    if (debt.isSynced == true && debt.debtId != null) return;

    try {
      final remoteDebt = await remote.addDebt(debt);

      debt
        ..debtId = remoteDebt.debtId
        ..isSynced = true;

      await local.updateDebt(debt);
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================
  // UPDATE SYNC
  // =========================================================
  @override
  Future<void> updateByLocalId(int localId) async {
    final debt = await local.getDebtByIsarId(localId);
    if (debt == null) return;

    // 🔴 لا يحدث إذا ليس لديه server id
    if (debt.debtId == null || debt.debtId == -1) return;

    try {
      await remote.updateDebt(debt);

      debt
        ..isSynced = true
        ..updatedAt = DateTime.now();

      await local.updateDebt(debt);
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================
  // DELETE SYNC
  // =========================================================
  @override
  Future<void> deleteByLocalId(int localId) async {
    final debt = await local.getDebtByIsarId(localId);
    if (debt == null) return;

    try {
      // 🔴 إذا لم يُرفع للسيرفر → حذف محلي فقط
      if (debt.debtId == null || debt.debtId == -1) {
        await local.deleteDebt(debt);
        return;
      }

      final isRemoved = await remote.deleteDebt(debt);

      if (!isRemoved) {
        throw Exception("Failed to delete debt from server");
      }

      await local.deleteDebt(debt);
    } catch (e) {
      rethrow;
    }
  }
}
