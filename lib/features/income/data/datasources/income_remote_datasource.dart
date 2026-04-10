import 'package:spendwise/features/income/data/models/income_model.dart';

abstract class IncomeRemoteDatasource {
  Future<IncomeModel> addIncome();
}
