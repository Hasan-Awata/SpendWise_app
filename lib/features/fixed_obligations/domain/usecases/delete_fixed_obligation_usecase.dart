// lib/features/fixed_obligations/domain/usecases/delete_fixed_obligation_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';
import 'package:spendwise/features/fixed_obligations/data/repositories/fixed_obligation_repository.dart';

class DeleteFixedObligationUseCase {
  final FixedObligationRepository repository;
  DeleteFixedObligationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(FixedObligationModel model) async {
    return await repository.deleteFixedObligation(model);
  }
}
