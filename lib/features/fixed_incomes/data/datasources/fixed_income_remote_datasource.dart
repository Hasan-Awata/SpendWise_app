import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';

abstract class FixedIncomeRemoteDataSource {
  FixedIncomeRemoteDataSource();

  Future<List<FixedIncomeModel>?> getFixedIncomes();
  Future<FixedIncomeModel?> addFixedIncome(FixedIncomeModel model);

  Future<FixedIncomeModel?> updateFixedIncome(FixedIncomeModel model);

  Future<bool> deleteFixedIncome(int id);
}
