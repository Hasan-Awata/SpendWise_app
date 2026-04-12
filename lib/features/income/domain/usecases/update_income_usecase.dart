import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class UpdateIncomeUseCase {
  final IncomeRepository repository;

  UpdateIncomeUseCase(this.repository);

  Future<void> call(int incomeId, IncomeModel income) async {
    return await repository.updateIncome(incomeId, income);
  }
}
