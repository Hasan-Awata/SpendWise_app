import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/debts/data/repositories/shared_debt_repository.dart';
import 'package:spendwise/features/debts/domain/entities/shared_debt_entity.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class GetDebtsUseCase {
  final SharedDebtRepository repository;

  GetDebtsUseCase(this.repository);

  Future<Either<Failure, List<SharedDebtEntity>>> call(
    int? userId,
    PageRequest page,
  ) {
    return repository.getDebts(userId);
  }
}
