import 'package:isar/isar.dart';
import 'package:spendwise/features/fixed_obligations/data/datasources/fixed_obligation_local_datasource.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';

class FixedObligationLocalDataSourceImpl
    implements FixedObligationLocalDataSource {
  final Isar isar;

  FixedObligationLocalDataSourceImpl(this.isar);

  // ========================= القراءة =========================
  @override
  Future<List<FixedObligationModel>> getFixedObligations() async {
    return await isar.fixedObligationModels.where().findAll();
  }

  // ========================= الإضافة والتحديث (دمجت المنطق) =========================
  @override
  Future<void> saveFixedObligation(FixedObligationModel model) async {
    // Isar يقوم بـ Upsert تلقائياً (إضافة إذا كان جديد، تحديث إذا كان موجوداً)
    await isar.writeTxn(() async {
      await isar.fixedObligationModels.put(model);
    });
  }

  @override
  Future<void> saveAll(List<FixedObligationModel> models) async {
    await isar.writeTxn(() async {
      await isar.fixedObligationModels.putAll(models);
    });
  }

  // ========================= الحذف =========================
  @override
  Future<void> deleteFixedObligation(int isarId) async {
    await isar.writeTxn(() async {
      await isar.fixedObligationModels.delete(isarId);
    });
  }

  // ========================= البحث =========================
  @override
  Future<FixedObligationModel?> getById(int id) async {
    return await isar.fixedObligationModels.filter().idEqualTo(id).findFirst();
  }

  @override
  Future<FixedObligationModel?> getFixedObligationByIsarId(int isarId) async {
    return isar.fixedObligationModels
        .filter()
        .isarIdEqualTo(isarId)
        .findFirstSync();
  }

  @override
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.fixedObligationModels.clear();
    });
  }
}
