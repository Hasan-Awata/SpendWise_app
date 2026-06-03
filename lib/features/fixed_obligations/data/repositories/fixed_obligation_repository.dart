import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';

abstract class FixedObligationRepository {
  FixedObligationRepository();

  Future<Either<Failure, String>> addFixedObligation(
    FixedObligationModel model,
  );

  Future<Either<Failure, Unit>> updateFixedObligation(
    FixedObligationModel model,
  );

  Future<Either<Failure, Unit>> deleteFixedObligation(
    FixedObligationModel model,
  );

  Future<Either<Failure, List<FixedObligationModel>>> getFixedObligations();
}
