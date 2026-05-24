// lib/features/transaction/data/datasources/transaction_local_datasource.dart
// TransactionLocalDataSource: Local storage interface managing transaction cache lifecycles, full resets, and data retrieval

import 'package:isar/isar.dart';
import 'package:spendwise/features/category/data/models/category_model.dart';

import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  // حفظ قائمة كاملة من المعاملات المالية
  Future<void> cacheTransactions(List<TransactionModel> models);

  // حفظ أو تحديث معاملة مالية فردية (مطلوبة للـ Loop في الـ Repository الجديد)
  Future<void> cacheTransaction(TransactionModel model);

  // جلب كافة المعاملات المخزنة محلياً لعمل الفلترة والـ Pagination بالـ Repository
  Future<List<TransactionModel>> getAllCachedTransactions();

  // مسح الكاش بالكامل لتجديد البيانات عند توفر الاتصال بالإنترنت
  Future<void> clear();

  // جلب الفئة المرتبطة بالمعاملة
  Future<CategoryModel?> getCachedCategory(int? categoryId);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Isar isar;

  TransactionLocalDataSourceImpl({required this.isar});

  @override
  Future<void> cacheTransactions(List<TransactionModel> models) async {
    await isar.writeTxn(() async {
      for (var model in models) {
        // Caching transactional node metrics dynamically using localId indexes
        await isar.transactionModels.putByLocalId(model);
      }
    });
  }

  @override
  Future<void> cacheTransaction(TransactionModel model) async {
    await isar.writeTxn(() async {
      // استخدام putByLocalId يعتمد على الـ Index الفريد للـ UUID لمنع تكرار الصفوف
      await isar.transactionModels.putByLocalId(model);
    });
  }

  @override
  Future<List<TransactionModel>> getAllCachedTransactions() async {
    // جلب كامل العناصر بدون Pagination محلي لتتمكن طبقة الـ Repository من ترتيبها وفلترتها بدقة
    return await isar.transactionModels.where().sortByDateDesc().findAll();
  }

  @override
  Future<void> clear() async {
    await isar.writeTxn(() async {
      // مسح كافة السجلات بداخل جدول الـ TransactionModels في Isar
      await isar.transactionModels.clear();
    });
  }

  @override
  Future<CategoryModel?> getCachedCategory(int? categoryId) async {
    if (categoryId == null) return null;
    return await isar.categoryModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .findFirst();
  }
}
