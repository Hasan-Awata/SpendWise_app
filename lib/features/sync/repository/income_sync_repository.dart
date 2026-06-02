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

    // 🔴 منع إعادة الإرسال إذا كان متزامن مسبقاً
    if (income.isSynced == true && income.id != null) return;

    try {
      final remoteIncome = await remote.addIncome(income);

      if (remoteIncome != null) {
        income
          ..id = remoteIncome.id
          ..isSynced = true;

        await local.updateIncome(income);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateByLocalId(int localId) async {
    final income = await local.getIncomeByIsarId(localId);
    if (income == null) return;

    // 🔴 لا تحدث إذا غير مرتبط بالسيرفر
    if (income.id == null) return;

    try {
      await remote.updateIncome(income);

      income.isSynced = true;
      await local.updateIncome(income);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteByLocalId(int localId) async {
    final income = await local.getIncomeByIsarId(localId);
    if (income == null) return;

    try {
      // 🔴 إذا غير مرفوع للسيرفر → حذف محلي فقط
      if (income.id == null || income.id == -1) {
        await local.deleteIncome(income);
        return;
      }

      final isRemoved = await remote.deleteIncome(income);

      if (!isRemoved) {
        throw Exception("Failed to delete income from server");
      }

      await local.deleteIncome(income);
    } catch (e) {
      rethrow;
    }
  }
}
