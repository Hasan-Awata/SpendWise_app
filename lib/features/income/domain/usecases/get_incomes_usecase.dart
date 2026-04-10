import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class GetIncomesUsecase {
  final IncomeRepository repository;
  GetIncomesUsecase(this.repository);

  Future<List<IncomeModel>> call() async {
    return repository.getIncomes();
  }
}
