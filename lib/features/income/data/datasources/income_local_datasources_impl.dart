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
    await _box.put(_incomeKey, incomes);
  }

  @override
  Future<void> addIncome(IncomeModel income) async {
    List<IncomeModel> incomes = getIncomes();
    incomes.add(income);
    await saveIncomes(incomes);
  }

  @override
  List<IncomeModel> getIncomes() {
    final List? data = _box.get(_incomeKey);
    return data != null ? List<IncomeModel>.from(data) : [];
  }

  @override
  Future<void> clear() async {
    await _box.delete(_incomeKey);
  }
}
