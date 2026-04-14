import 'package:hive_flutter/hive_flutter.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';

// // Implementation: How Hive actually handles the data
class IncomeLocalDataSourceImpl implements IncomeLocalDataSource {
  static final IncomeLocalDataSourceImpl _instance =
      IncomeLocalDataSourceImpl._internal();
  factory IncomeLocalDataSourceImpl() => _instance;
  IncomeLocalDataSourceImpl._internal();

  static const String _boxName = 'MYINCOME';
  static const String _incomeKey = 'all_incomes';

  late Box _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<void> saveIncomes(List<IncomeModel> incomes) async {
    try {
      await _box.put(_incomeKey, incomes);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> addIncome(IncomeModel income) async {
    List<IncomeModel> incomes = await getIncomes();
    incomes.insert(0, income);
    await saveIncomes(incomes);
  }

  @override
  Future<List<IncomeModel>> getIncomes() async {
    final List? data = await _box.get(_incomeKey);
    return data != null ? List<IncomeModel>.from(data) : <IncomeModel>[];
  }

  @override
  Future<void> deleteIncome(int incomeId) async {
    List<IncomeModel> incomes = await getIncomes();

    incomes.removeWhere((element) => element.id == incomeId);

    await saveIncomes(incomes);
  }

  @override
  Future<void> updateIncome(IncomeModel income) async {
    List<IncomeModel> incomes = await getIncomes();

    int index = incomes.indexWhere((element) => element.id == income.id);

    if (index != -1) {
      incomes[index] = income;
      await saveIncomes(incomes);
    }
  }

  @override
  Future<void> clear() async {
    await _box.delete(_incomeKey);
  }
}
