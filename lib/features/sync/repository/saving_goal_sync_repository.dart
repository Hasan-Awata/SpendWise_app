// lib/features/savings_goals/data/repositories/saving_goal_sync_repository.dart
// SavingGoalSyncRepository: Processes individual queued operations from SyncQueue to synchronize local records with the .NET cloud infrastructure

import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_remote_datasource.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

class SavingGoalSyncRepository implements SyncRepository<SavingGoalModel> {
  final SavingGoalLocalDataSource local;
  final SavingGoalRemoteDatasource remote;

  SavingGoalSyncRepository({required this.local, required this.remote});

  @override
  Future<void> createByLocalId(int isarId) async {
    final savingGoal = await local.getSavingGoalByIsarId(isarId);
    if (savingGoal == null) return;

    // منع تكرار الإرسال إذا تمت المزامنة بنجاح مسبقاً وتوفر الـ Identifier الخارجي
    if (savingGoal.isSynced == true &&
        savingGoal.goalId != null &&
        savingGoal.goalId != -1)
      return;

    try {
      final remoteSavingGoal = await remote.addGoal(savingGoal);

      savingGoal
        ..goalId = remoteSavingGoal.goalId
        ..isSynced = true;

      await local.updateSavingGoal(savingGoal);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateByLocalId(int isarId) async {
    final savingGoal = await local.getSavingGoalByIsarId(isarId);
    if (savingGoal == null) return;

    // لا يتم التحديث على السيرفر إذا كان السجل غير مربوط بمعرف خارجي أصلاً (يجب إنشاؤه أولاً)
    if (savingGoal.goalId == null || savingGoal.goalId == -1) return;

    try {
      await remote.updateGoal(savingGoal);

      savingGoal.isSynced = true;
      await local.updateSavingGoal(savingGoal);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteByLocalId(int isarId) async {
    final savingGoal = await local.getSavingGoalByIsarId(isarId);
    if (savingGoal == null) return;

    try {
      // إذا كان السجل غير متوفر على السيرفر، يتم تدميره محلياً بشكل فوري ومنع تعليق الطابور
      if (savingGoal.goalId == null || savingGoal.goalId == -1) {
        await local.deleteSavingGoal(savingGoal);
        return;
      }

      final isRemoved = await remote.deleteGoal(savingGoal.goalId!);

      if (isRemoved) {
        await local.deleteSavingGoal(savingGoal);
      }
    } catch (e) {
      rethrow;
    }
  }
}
