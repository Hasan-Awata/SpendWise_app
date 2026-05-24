import 'package:isar/isar.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';

class IncomeLocalDataSourceImpl implements IncomeLocalDataSource {
  // نسخة Isar الممررة عبر التبعيات
  final Isar isar;

  IncomeLocalDataSourceImpl(this.isar);

  // ========================= GET =========================
  @override
  Future<List<IncomeModel>> getIncomes() async {
    try {
      // جلب كافة السجلات وترتيبها تنازلياً حسب التاريخ لضمان ظهور الأحدث أولاً
      return await isar.incomeModels.where().sortByDateDesc().findAll();
    } catch (e) {
      print("❌ Error fetching incomes from Isar: $e");
      return [];
    }
  }

  // ========================= ADD / SAVE =========================
  @override
  Future<void> addIncome(IncomeModel income) async {
    try {
      await isar.writeTxn(() async {
        await isar.incomeModels.put(
          income,
        ); // سيقوم بالإدخال أو التحديث بناءً على localId
      });
      print("✅ Income added locally: ${income.title}");
    } catch (e) {
      print("❌ Error adding income to Isar: $e");
      rethrow;
    }
  }

  @override
  Future<void> saveIncomes(List<IncomeModel> incomes) async {
    try {
      await isar.writeTxn(() async {
        // استخدام putAll للتعامل مع القوائم الكبيرة بكفاءة عالية
        await isar.incomeModels.putAll(incomes);
      });
    } catch (e) {
      print("❌ Error bulk saving incomes to Isar: $e");
      rethrow;
    }
  }

  // ========================= UPDATE =========================
  @override
  Future<void> updateIncome(IncomeModel income) async {
    try {
      await isar.writeTxn(() async {
        // البحث عن السجل بناءً على الفهرس الفريد localId وتحديثه
        await isar.incomeModels.put(income);
      });
      print("✅ Income updated locally: ${income.title}");
    } catch (e) {
      print("❌ Error updating income in Isar: $e");
      rethrow;
    }
  }

  // ========================= DELETE =========================
  @override
  Future<void> deleteIncome(IncomeModel income) async {
    try {
      await isar.writeTxn(() async {
        // الحذف باستخدام معرف Isar الرقمي (isarId) المولد من localId
        await isar.incomeModels.delete(income.isarId);
      });
      print("✅ Income deleted locally: ${income.title}");
    } catch (e) {
      print("❌ Error deleting income from Isar: $e");
      rethrow;
    }
  }

  @override
  Future<IncomeModel?> getIncome(String localId) async {
    return isar.incomeModels.filter().localIdEqualTo(localId).findFirstSync();
  }

  @override
  IncomeModel? getIncomeByServerId(int? walletId) {
    if (walletId == null) return null;

    return isar.incomeModels.filter().walletIdEqualTo(walletId).findFirstSync();
  }

  @override
  Future<bool> checkIfIncomeExists(String localId) async {
    // استخدام query مباشر للبحث عن الـ localId فقط دون جلب كافة البيانات للذاكرة
    final count = await isar.incomeModels
        .filter()
        .localIdEqualTo(localId)
        .count();

    return count > 0;
  }

  @override
  Future<bool> checkIfIncomeExistsById(int? id) async {
    // استخدام query مباشر للبحث عن الـ localId فقط دون جلب كافة البيانات للذاكرة
    final count = await isar.incomeModels.filter().idEqualTo(id).count();

    return count > 0;
  }

  @override
  Future<void> saveOrUpdateRemoteIncome(IncomeModel remoteIncome) async {
    await isar.writeTxn(() async {
      // 1. البحث عن سجل محلي يمتلك نفس المعرف الخاص بالسيرفر
      final existing = await isar.incomeModels
          .filter()
          .idEqualTo(remoteIncome.id)
          .findFirst();

      if (existing != null) {
        // 2. إذا وجد، نقوم بتحديث البيانات مع الحفاظ على الهوية المحلية (isarId & localId)
        remoteIncome.isarId = existing.isarId;
        remoteIncome.localId = existing.localId;

        // نضع علامة المزامنة لأن البيانات قادمة من السيرفر أصلاً
        remoteIncome.isSynced = true;

        await isar.incomeModels.put(remoteIncome);
      } else {
        // 3. إذا لم يوجد، نتحقق أولاً أنه ليس "محذوفاً محلياً" قبل إضافته
        // (اختياري: لمنع السيرفر من إعادة بيانات حذفها المستخدم وهو Offline)
        remoteIncome.isSynced = true;
        await isar.incomeModels.put(remoteIncome);
      }
    });
  }

  // ========================= CLEAR =========================
  @override
  Future<void> clear() async {
    try {
      await isar.writeTxn(() async {
        await isar.incomeModels.clear();
      });
      print("🧹 Income local storage cleared");
    } catch (e) {
      print("❌ Error clearing income storage: $e");
    }
  }

  @override
  Future<IncomeModel?> getIncomeByIsarId(int? isarId) async {
    if (isarId == null) return null;

    return isar.incomeModels.filter().isarIdEqualTo(isarId).findFirstSync();
  }
}
