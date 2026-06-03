import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';

abstract class FixedIncomeLocalDataSource {
  FixedIncomeLocalDataSource();

  Future<List<FixedIncomeModel>> getFixedIncomes();
  Future<void> saveFixedIncome(FixedIncomeModel model);
  Future<void> saveAll(List<FixedIncomeModel> models);
  Future<void> deleteFixedIncome(int isarId);
  Future<FixedIncomeModel?> getById(int id);
  Future<FixedIncomeModel?> getFixedIncomeByIsarId(int isarId);
  Future<void> clear();
}
