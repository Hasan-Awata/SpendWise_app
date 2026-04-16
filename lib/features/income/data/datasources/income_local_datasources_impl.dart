import 'package:get/get.dart';
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
  Future<void> deleteIncome(IncomeModel income) async {
    List<IncomeModel> incomes = await getIncomes();

    IncomeModel? newincome = incomes.firstWhereOrNull(
      (element) => element.localId == income.localId,
    );
    if (newincome != null) {
      newincome.localId = "REMOVE";
    }
  }

  @override
  Future<void> updateIncome(IncomeModel income) async {
    List<IncomeModel> incomes = await getIncomes();

    try {
      int index = incomes.indexWhere((w) => w.localId == income.localId);
      if (index != -1) {
        incomes[index] = income;
      }
      await _box.put(_incomeKey, incomes);
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    await _box.delete(_incomeKey);
  }
}
