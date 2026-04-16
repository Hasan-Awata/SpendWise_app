// // Contract: Defining what the local data source should do
import 'package:spendwise/features/income/data/models/income_model.dart';

abstract class IncomeLocalDataSource {
  Future<void> init();
  Future<void> saveIncomes(List<IncomeModel> incomes);
  Future<void> addIncome(IncomeModel income);
  Future<List<IncomeModel>> getIncomes();
  Future<void> deleteIncome(IncomeModel income);
  Future<void> updateIncome(IncomeModel income);
  Future<void> clear();
}
