import 'package:isar/isar.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';

class SavingGoalLocalDatasourceImpl implements SavingGoalLocalDatasource {
  // نسخة Isar المحقونة عبر الـ Constructor لضمان سهولة الاختبار (Testing)
  final Isar isar;

  SavingGoalLocalDatasourceImpl(this.isar);

  // ========================= جلب كافة الأهداف =========================
  @override
  Future<List<SavingGoalModel>> getAllGoalsLocal() async {
    try {
      // جلب كافة الأهداف من Isar
      return await isar.savingGoalModels.where().findAll();
    } catch (e) {
      print("❌ Error fetching saving goals from Isar: $e");
      return [];
    }
  }

  // ========================= تحديث أو إضافة هدف =========================
  @override
  Future<void> updateGoalLocal(SavingGoalModel goal) async {
    try {
      await isar.writeTxn(() async {
        // Isar يعتمد على المعرف الفريد (isarId) المولد من الـ id
        // للقيام بعملية put (تحديث إذا وجد السجل أو إضافة إذا لم يوجد)
        await isar.savingGoalModels.put(goal);
      });
      print("✅ Saving Goal updated/added: ${goal.isarId}");
    } catch (e) {
      print("❌ Error updating saving goal in Isar: $e");
      rethrow;
    }
  }

  // ========================= حذف هدف =========================
  @override
  Future<void> deleteGoalLocal(int id) async {
    try {
      // تحويل الـ String id إلى المعرف الرقمي الخاص بـ Isar للحذف السريع
      final isarId = isar.savingGoalModels
          .where()
          .isarIdEqualTo(id)
          .findFirstSync()
          ?.isarId;

      if (isarId != null) {
        await isar.writeTxn(() async {
          await isar.savingGoalModels.delete(isarId);
        });
        print("✅ Saving Goal deleted: $id");
      }
    } catch (e) {
      print("❌ Error deleting saving goal from Isar: $e");
      rethrow;
    }
  }

  @override
  SavingGoalModel? getSavingGoal(String localId) {
    return isar.savingGoalModels
        .filter()
        .localIdEqualTo(localId)
        .findFirstSync();
  }

  @override
  SavingGoalModel? getSavingGoalByServerId(int? savingGoalId) {
    if (savingGoalId == null) return null;

    return isar.savingGoalModels
        .filter()
        .goalIdEqualTo(savingGoalId)
        .findFirstSync();
  }

  @override
  Future<void> clear() async {
    try {
      await isar.writeTxn(() async {
        await isar.savingGoalModels.clear();
      });
      print("🧹 Saving Goals local storage cleared");
    } catch (e) {
      print("❌ Error clearing Saving Goals storage: $e");
    }
  }
}
