import 'package:isar/isar.dart';
import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_local_datasource.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';

class FixedIncomeLocalDataSourceImpl implements FixedIncomeLocalDataSource {
  final Isar isar;

  FixedIncomeLocalDataSourceImpl(this.isar);

  // ========================= القراءة =========================
  @override
  Future<List<FixedIncomeModel>> getFixedIncomes() async {
    return await isar.fixedIncomeModels.where().findAll();
  }

  // ========================= الإضافة والتحديث (دمجت المنطق) =========================
  @override
  Future<void> saveFixedIncome(FixedIncomeModel model) async {
    // Isar يقوم بـ Upsert تلقائياً (إضافة إذا كان جديد، تحديث إذا كان موجوداً)
    await isar.writeTxn(() async {
      await isar.fixedIncomeModels.put(model);
    });
  }

  @override
  Future<void> saveAll(List<FixedIncomeModel> models) async {
    await isar.writeTxn(() async {
      await isar.fixedIncomeModels.putAll(models);
    });
  }

  // ========================= الحذف =========================
  @override
  Future<void> deleteFixedIncome(int isarId) async {
    await isar.writeTxn(() async {
      await isar.fixedIncomeModels.delete(isarId);
    });
  }

  // ========================= البحث =========================
  @override
  Future<FixedIncomeModel?> getById(int id) async {
    return await isar.fixedIncomeModels
        .filter()
        .fixedIncomeIdEqualTo(id)
        .findFirst();
  }

  @override
  Future<FixedIncomeModel?> getFixedIncomeByIsarId(int isarId) async {
    return isar.fixedIncomeModels
        .filter()
        .isarIdEqualTo(isarId)
        .findFirstSync();
  }

  @override
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.fixedIncomeModels.clear();
    });
  }
}
