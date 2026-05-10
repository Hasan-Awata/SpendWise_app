import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class GetIncomesUsecase {
  final IncomeRepository repository;
  GetIncomesUsecase(this.repository);

  Future<Either<Failure, PagedResponse<IncomeEntity>>> call(
    int? userId,
    PageRequest page,
  ) async {
    return repository.getIncomes(userId, page);
  }
}
