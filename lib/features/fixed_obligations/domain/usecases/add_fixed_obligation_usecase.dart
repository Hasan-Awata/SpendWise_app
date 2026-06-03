// lib/features/fixed_obligations/domain/usecases/add_fixed_obligation_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';
import 'package:spendwise/features/fixed_obligations/data/repositories/fixed_obligation_repository.dart';

class AddFixedObligationUseCase {
  final FixedObligationRepository repository;
  AddFixedObligationUseCase(this.repository);

  Future<Either<Failure, String>> call(FixedObligationModel model) async {
    return await repository.addFixedObligation(model);
  }
}
