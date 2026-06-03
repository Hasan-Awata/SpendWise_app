import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_local_datasource.dart';
import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_remote_datasource.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

class FixedIncomeSyncRepository implements SyncRepository<FixedIncomeModel> {
  final FixedIncomeLocalDataSource local;
  final FixedIncomeRemoteDataSource remote;

  FixedIncomeSyncRepository({required this.local, required this.remote});

  @override
  Future<void> createByLocalId(int isarId) async {
    final fixedIncome = await local.getFixedIncomeByIsarId(isarId);
    if (fixedIncome == null) return;

    if (fixedIncome.isSynced == true) return;

    try {
      // 1. استدعاء السيرفر (يبقى كما هو)
      final remoteFixedIncome = await remote.addFixedIncome(fixedIncome);

      if (remoteFixedIncome != null) {
        // 2. تحديث الموديل بالحالة القادمة من السيرفر
        fixedIncome
          ..fixedIncomeId = remoteFixedIncome.fixedIncomeId
          ..isSynced = true;

        await local.saveFixedIncome(fixedIncome);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateByLocalId(int isarId) async {
    final fixedIncome = await local.getFixedIncomeByIsarId(isarId);
    if (fixedIncome == null) return;

    try {
      await remote.updateFixedIncome(fixedIncome);

      fixedIncome.isSynced = true;
      await local.saveFixedIncome(fixedIncome);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteByLocalId(int isarId) async {
    final fixedIncome = await local.getFixedIncomeByIsarId(isarId);
    if (fixedIncome == null) return;

    try {
      bool isRemoved = false;

      // 🔴 إذا غير موجود على السيرفر نحذفه محلياً مباشرة
      if (fixedIncome.fixedIncomeId == -1) {
        await local.deleteFixedIncome(fixedIncome.isarId);
        return;
      }

      isRemoved = await remote.deleteFixedIncome(fixedIncome.isarId);

      if (isRemoved) {
        await local.deleteFixedIncome(fixedIncome.isarId);
      }
    } catch (e) {
      rethrow;
    }
  }
}
