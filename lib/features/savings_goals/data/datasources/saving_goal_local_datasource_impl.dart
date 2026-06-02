import 'package:isar/isar.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';

class SavingGoalLocalDataSourceImpl implements SavingGoalLocalDataSource {
  // نسخة Isar الممررة عبر التبعيات
  final Isar isar;

  SavingGoalLocalDataSourceImpl(this.isar);

  // ========================= GET =========================
  @override
  Future<List<SavingGoalModel>> getSavingGoals() async {
    try {
      return await isar.savingGoalModels.where().sortByCreatedAt().findAll();
    } catch (e) {
      print("❌ Error fetching SavingGoals from Isar: $e");
      return [];
    }
  }

  // ========================= ADD / SAVE =========================
  @override
  Future<void> addSavingGoal(SavingGoalModel savingGoal) async {
    try {
      await isar.writeTxn(() async {
        await isar.savingGoalModels.put(
          savingGoal,
        ); // سيقوم بالإدخال أو التحديث بناءً على localId
      });
      print("✅ SavingGoal added locally: ${savingGoal.title}");
    } catch (e) {
      print("❌ Error adding SavingGoal to Isar: $e");
      rethrow;
    }
  }

  @override
  Future<void> saveSavingGoals(List<SavingGoalModel> savingGoals) async {
    try {
      await isar.writeTxn(() async {
        // استخدام putAll للتعامل مع القوائم الكبيرة بكفاءة عالية
        await isar.savingGoalModels.putAll(savingGoals);
      });
    } catch (e) {
      print("❌ Error bulk saving SavingGoals to Isar: $e");
      rethrow;
    }
  }

  // ========================= UPDATE =========================
  @override
  Future<void> updateSavingGoal(SavingGoalModel savingGoal) async {
    try {
      await isar.writeTxn(() async {
        // البحث عن السجل بناءً على الفهرس الفريد localId وتحديثه
        await isar.savingGoalModels.put(savingGoal);
      });
      print("✅ SavingGoal updated locally: ${savingGoal.title}");
    } catch (e) {
      print("❌ Error updating SavingGoal in Isar: $e");
      rethrow;
    }
  }

  // ========================= DELETE =========================
  @override
  Future<void> deleteSavingGoal(SavingGoalModel savingGoal) async {
    try {
      await isar.writeTxn(() async {
        // الحذف باستخدام معرف Isar الرقمي (isarId) المولد من localId
        await isar.savingGoalModels.delete(savingGoal.isarId);
      });
      print("✅ SavingGoal deleted locally: ${savingGoal.title}");
    } catch (e) {
      print("❌ Error deleting SavingGoal from Isar: $e");
      rethrow;
    }
  }

  @override
  Future<SavingGoalModel?> getSavingGoal(String localId) async {
    return isar.savingGoalModels
        .filter()
        .localIdEqualTo(localId)
        .findFirstSync();
  }

  @override
  SavingGoalModel? getSavingGoalByServerId(int? walletId) {
    if (walletId == null) return null;

    return isar.savingGoalModels
        .filter()
        .goalIdEqualTo(walletId)
        .findFirstSync();
  }

  @override
  Future<bool> checkIfSavingGoalExists(String localId) async {
    // استخدام query مباشر للبحث عن الـ localId فقط دون جلب كافة البيانات للذاكرة
    final count = await isar.savingGoalModels
        .filter()
        .localIdEqualTo(localId)
        .count();

    return count > 0;
  }

  @override
  Future<bool> checkIfSavingGoalExistsById(int? id) async {
    // استخدام query مباشر للبحث عن الـ localId فقط دون جلب كافة البيانات للذاكرة
    final count = await isar.savingGoalModels
        .filter()
        .goalIdEqualTo(id)
        .count();

    return count > 0;
  }

  @override
  Future<void> saveOrUpdateRemoteSavingGoal(
    SavingGoalModel remoteSavingGoal,
  ) async {
    await isar.writeTxn(() async {
      // 1. البحث عن سجل محلي يمتلك نفس المعرف الخاص بالسيرفر
      final existing = await isar.savingGoalModels
          .filter()
          .goalIdEqualTo(remoteSavingGoal.goalId)
          .findFirst();

      if (existing != null) {
        // 2. إذا وجد، نقوم بتحديث البيانات مع الحفاظ على الهوية المحلية (isarId & localId)
        remoteSavingGoal.isarId = existing.isarId;
        remoteSavingGoal.localId = existing.localId;

        // نضع علامة المزامنة لأن البيانات قادمة من السيرفر أصلاً
        remoteSavingGoal.isSynced = true;

        await isar.savingGoalModels.put(remoteSavingGoal);
      } else {
        // 3. إذا لم يوجد، نتحقق أولاً أنه ليس "محذوفاً محلياً" قبل إضافته
        // (اختياري: لمنع السيرفر من إعادة بيانات حذفها المستخدم وهو Offline)
        remoteSavingGoal.isSynced = true;
        await isar.savingGoalModels.put(remoteSavingGoal);
      }
    });
  }

  // ========================= CLEAR =========================
  @override
  Future<void> clear() async {
    try {
      await isar.writeTxn(() async {
        await isar.savingGoalModels.clear();
      });
      print("🧹 SavingGoal local storage cleared");
    } catch (e) {
      print("❌ Error clearing SavingGoal storage: $e");
    }
  }

  @override
  Future<SavingGoalModel?> getSavingGoalByIsarId(int? isarId) async {
    if (isarId == null) return null;

    return isar.savingGoalModels.filter().isarIdEqualTo(isarId).findFirstSync();
  }
}
