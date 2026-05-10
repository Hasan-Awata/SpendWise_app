import 'package:isar/isar.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  // نسخة Isar المحقونة عبر المشيد
  final Isar isar;

  ExpenseLocalDataSourceImpl(this.isar);

  // ========================= القراءة =========================
  @override
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      // جلب المصاريف مرتبة من الأحدث إلى الأقدم
      return await isar.expenseModels.where().sortByDateDesc().findAll();
    } catch (e) {
      print("❌ Error fetching expenses: $e");
      return [];
    }
  }

  // ========================= الإضافة والحفظ =========================
  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await isar.writeTxn(() async {
        await isar.expenseModels.put(expense);
      });
      print("✅ Expense added/updated: ${expense.title}");
    } catch (e) {
      print("❌ Error adding expense: $e");
      rethrow;
    }
  }

  @override
  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    try {
      await isar.writeTxn(() async {
        // استخدام putAll للتعامل مع المزامنة الضخمة بكفاءة
        await isar.expenseModels.putAll(expenses as dynamic);
        // ملاحظة: تأكد من تمرير النوع الصحيح أو تحويل القائمة
        await isar.expenseModels.putAll(expenses);
      });
    } catch (e) {
      print("❌ Error bulk saving expenses: $e");
      rethrow;
    }
  }

  // ========================= التحديث =========================
  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await isar.writeTxn(() async {
        // بما أن localId فريد ومربوط بـ isarId، الـ put ستقوم بالتحديث تلقائياً
        await isar.expenseModels.put(expense);
      });
    } catch (e) {
      print("❌ Error updating expense: $e");
      rethrow;
    }
  }

  // ========================= الحذف =========================
  @override
  Future<void> deleteExpense(ExpenseModel expense) async {
    try {
      await isar.writeTxn(() async {
        // الحذف المباشر باستخدام المعرف الرقمي السريع
        await isar.expenseModels.delete(expense.isarId);
      });
      print("✅ Expense deleted: ${expense.title}");
    } catch (e) {
      print("❌ Error deleting expense: $e");
      rethrow;
    }
  }

  @override
  ExpenseModel? getExpense(String localId) {
    return isar.expenseModels.filter().localIdEqualTo(localId).findFirstSync();
  }

  @override
  ExpenseModel? getExpenseByServerId(int? walletId) {
    if (walletId == null) return null;

    return isar.expenseModels
        .filter()
        .walletIdEqualTo(walletId)
        .findFirstSync();
  }

  @override
  Future<bool> checkIfExpenseExists(String localId) async {
    // استخدام query مباشر للبحث عن الـ localId فقط دون جلب كافة البيانات للذاكرة
    final count = await isar.expenseModels
        .filter()
        .localIdEqualTo(localId)
        .count();

    return count > 0;
  }

  // ========================= المسح الشامل =========================
  @override
  Future<void> clear() async {
    try {
      await isar.writeTxn(() async {
        await isar.expenseModels.clear();
      });
      print("🧹 Expense local storage cleared");
    } catch (e) {
      print("❌ Error clearing expenses: $e");
    }
  }
}
