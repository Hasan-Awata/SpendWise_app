import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';
import 'package:spendwise/features/fixed_obligations/data/repositories/fixed_obligation_repository.dart';

class GetFixedObligationsUseCase {
  final FixedObligationRepository repository;
  GetFixedObligationsUseCase(this.repository);

  Future<Either<Failure, List<FixedObligationModel>>> call() async {
    return await repository.getFixedObligations();
  }
}
