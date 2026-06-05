import 'package:isar/isar.dart';
import 'package:spendwise/features/debts/data/models/shared_debt_model.dart';

abstract class SharedDebtLocalDataSource {
  final Isar isar;

  SharedDebtLocalDataSource(this.isar);

  // ========================= GET =========================

  Future<List<SharedDebtModel>> getDebts();

  Future<SharedDebtModel?> getDebt(String localId);

  Future<SharedDebtModel?> getDebtByIsarId(int? isarId);

  SharedDebtModel? getDebtByServerId(int? debtId);
  Future<void> addDebt(SharedDebtModel debt);

  Future<void> saveDebts(List<SharedDebtModel> debts);
  Future<void> updateDebt(SharedDebtModel debt);

  Future<void> deleteDebt(SharedDebtModel debt);
  Future<bool> checkIfDebtExists(String localId);

  Future<bool> checkIfDebtExistsById(int? debtId);

  Future<void> saveOrUpdateRemoteDebt(SharedDebtModel remoteDebt);
  Future<void> clear();
}
