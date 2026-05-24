// =========================================================================
// مستودع مزامنة الدخل (Incomes) - يقوم بمعالجة عناصر طابور المزامنة الخاصة بالدخل
// =========================================================================

import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

class IncomeSyncRepository implements SyncRepository<IncomeModel> {
  final IncomeLocalDataSource local;
  final IncomeRemoteDatasource remote;

  IncomeSyncRepository({required this.local, required this.remote});

  @override
  Future<void> createByLocalId(int localId) async {
    final income = await local.getIncomeByIsarId(localId);
    if (income == null) return;

    final remoteIncome = await remote.addIncome(income);
    if (remoteIncome != null) {
      income
        ..id = remoteIncome.id
        ..isSynced = true;
      await local.updateIncome(income);
    }
  }

  @override
  Future<void> updateByLocalId(int localId) async {
    final income = await local.getIncomeByIsarId(localId);
    if (income == null) return;

    await remote.updateIncome(income);
    income.isSynced = true;
    await local.updateIncome(income);
  }

  @override
  Future<void> deleteByLocalId(int localId) async {
    final income = await local.getIncomeByIsarId(localId);

    if (income == null) return;

    // =========================
    // إذا العنصر غير متزامن مع السيرفر
    // نحذفه محلياً مباشرة
    // =========================

    if (income.id == null || income.id == -1) {
      await local.deleteIncome(income);
      return;
    }

    // =========================
    // حذف من السيرفر
    // =========================

    final isRemoved = await remote.deleteIncome(income);

    if (!isRemoved) {
      throw Exception("فشل حذف التاج من السيرفر");
    }

    // =========================
    // حذف محلي بعد نجاح السيرفر
    // =========================

    await local.deleteIncome(income);
  }
}
