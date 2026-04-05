import 'package:spendwise/features/income/data/models/income_model.dart';

abstract class IncomeRepository {
  Future<void> addIncome(IncomeModel income);
  List<IncomeModel> getIncomes();
}
