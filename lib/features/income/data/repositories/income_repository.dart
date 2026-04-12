import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

abstract class IncomeRepository {
  Future<void> addIncome(IncomeModel income);
  Future<List<IncomeModel>> getIncomes(int? userId, PageRequest page);
  Future<List<IncomeModel>> getAllIncomesLocal();
  Future<void> deleteIncome(int incomeId);
  Future<void> updateIncome(int incomeId, IncomeModel income);
}
