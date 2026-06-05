import 'package:spendwise/features/debts/data/models/shared_debt_model.dart';

abstract class SharedDebtRemoteDatasource {
  Future<List<SharedDebtModel>> getMyDebts(int userId);

  Future<SharedDebtModel> addDebt(SharedDebtModel debt);
  Future<void> updateDebt(SharedDebtModel debt);

  Future<bool> deleteDebt(SharedDebtModel debt);
}
