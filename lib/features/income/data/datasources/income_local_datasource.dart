// // Contract: Defining what the local data source should do
import 'package:spendwise/features/income/data/models/income_model.dart';

abstract class IncomeLocalDataSource {
  Future<void> saveIncomes(List<IncomeModel> incomes);
  Future<void> addIncome(IncomeModel income);
  Future<List<IncomeModel>> getIncomes();
  IncomeModel? getIncomeByServerId(int? walletId);
  IncomeModel? getIncome(String localId);
  Future<void> deleteIncome(IncomeModel income);
  Future<void> updateIncome(IncomeModel income);
  // داخل abstract class IncomeLocalDataSource
  Future<bool> checkIfIncomeExists(String localId);
  Future<void> clear();
}
