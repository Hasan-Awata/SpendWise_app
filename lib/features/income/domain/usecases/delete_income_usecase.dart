import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class DeleteIncomeUseCase {
  final IncomeRepository repository;

  DeleteIncomeUseCase(this.repository);

  Future<void> call(int incomeId) async {
    return await repository.deleteIncome(incomeId);
  }
}
