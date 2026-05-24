// =========================================================================
// مستودع مزامنة المصاريف (Expenses) - يقوم بمعالجة عناصر طابور المزامنة الخاصة بالمصاريف
// =========================================================================

import 'package:spendwise/features/expense/data/datasources/expense_local_datasource.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

class ExpenseSyncRepository implements SyncRepository<ExpenseModel> {
  final ExpenseLocalDataSource local;
  final ExpenseRemoteDataSource remote;

  ExpenseSyncRepository({required this.local, required this.remote});

  @override
  Future<void> createByLocalId(int isarId) async {
    final expense = await local.getExpenseByIsarId(isarId);
    if (expense == null) return;

    final remoteExpense = await remote.addExpense(expense);
    if (remoteExpense != null) {
      expense
        ..id = remoteExpense.id
        ..isSynced = true;
      await local.updateExpense(expense);
    }
  }

  @override
  Future<void> updateByLocalId(int isarId) async {
    final expense = await local.getExpenseByIsarId(isarId);

    await remote.updateExpense(expense!);
    expense.isSynced = true;
    await local.updateExpense(expense);
  }

  @override
  Future<void> deleteByLocalId(int isarId) async {
    final expense = await local.getExpenseByIsarId(isarId);
    bool isRemoved = false;
    if (expense == null) return;

    if (expense.id != null && expense.id != -1) {
      isRemoved = await remote.deleteExpense(expense);
    }
    if (isRemoved) {
      await local.deleteExpense(expense);
    }
  }
}
