import 'package:spendwise/features/expense/data/datasources/expense_local_datasource.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

class ExpenseSyncRepository implements SyncRepository<ExpenseModel> {
  final ExpenseLocalDataSource local;
  final ExpenseRemoteDataSource remote;

  ExpenseSyncRepository({required this.local, required this.remote});

  @override
  Future<void> createByLocalId(int isarId) async {
    final expense = await local.getExpenseByIsarId(isarId);
    if (expense == null) return;

    if (expense.isSynced == true && expense.id != null) return;

    try {
      // 1. استدعاء السيرفر (يبقى كما هو)
      final remoteExpense = await remote.addExpense(expense);

      if (remoteExpense != null) {
        // 2. تحديث الموديل بالحالة القادمة من السيرفر
        expense
          ..id = remoteExpense.id
          ..isSynced = true
          ..isOverLimit = remoteExpense.isOverLimit; // تحديث حالة الميزانية

        await local.updateExpense(expense);

        if (remoteExpense.isOverLimit == true) {
          HelperFunction.showSnackBar(
            "تنبيه ميزانية",
            "لقد تجاوزت الميزانية المحددة للفئة في هذا المصروف",
            isError: true,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateByLocalId(int isarId) async {
    final expense = await local.getExpenseByIsarId(isarId);
    if (expense == null) return;

    // 🔴 لا يحدث إذا غير مربوط بالسيرفر
    if (expense.id == null) return;

    try {
      await remote.updateExpense(expense);

      expense.isSynced = true;
      await local.updateExpense(expense);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteByLocalId(int isarId) async {
    final expense = await local.getExpenseByIsarId(isarId);
    if (expense == null) return;

    try {
      bool isRemoved = false;

      // 🔴 إذا غير موجود على السيرفر نحذفه محلياً مباشرة
      if (expense.id == null || expense.id == -1) {
        await local.deleteExpense(expense);
        return;
      }

      isRemoved = await remote.deleteExpense(expense);

      if (isRemoved) {
        await local.deleteExpense(expense);
      }
    } catch (e) {
      rethrow;
    }
  }
}
