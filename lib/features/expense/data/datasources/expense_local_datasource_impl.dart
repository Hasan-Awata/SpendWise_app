// // Implementation: features/expense/data/datasources/expense_local_datasource_impl.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'expense_local_datasource.dart';

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  static final ExpenseLocalDataSourceImpl _instance =
      ExpenseLocalDataSourceImpl._internal();
  factory ExpenseLocalDataSourceImpl() => _instance;
  ExpenseLocalDataSourceImpl._internal();

  static const String _boxName = 'MYEXPENSE';
  static const String _expenseKey = 'all_expenses';

  late Box _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    try {
      await _box.put(_expenseKey, expenses);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    List<ExpenseModel> expenses = await getExpenses();
    expenses.insert(0, expense);
    await saveExpenses(expenses);
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final List? data = await _box.get(_expenseKey);
    return data != null ? List<ExpenseModel>.from(data) : <ExpenseModel>[];
  }

  @override
  Future<void> deleteExpense(ExpenseModel expense) async {
    List<ExpenseModel> expenses = await getExpenses();
    expenses.removeWhere((element) => element.localId == expense.localId);
    await saveExpenses(expenses);
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    List<ExpenseModel> expenses = await getExpenses();
    int index = expenses.indexWhere(
      (element) => element.localId == expense.localId,
    );
    if (index != -1) {
      expenses[index] = expense;
      await saveExpenses(expenses);
    }
  }

  @override
  Future<void> clear() async {
    await _box.delete(_expenseKey);
  }
}
