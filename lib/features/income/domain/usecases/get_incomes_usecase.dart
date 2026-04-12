import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class GetIncomesUsecase {
  final IncomeRepository repository;
  GetIncomesUsecase(this.repository);

  Future<List<IncomeModel>> call(int? userId, PageRequest page) async {
    return repository.getIncomes(userId, page);
  }
}
