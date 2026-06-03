import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';

abstract class FixedObligationRemoteDataSource {
  FixedObligationRemoteDataSource();

  Future<List<FixedObligationModel>?> getFixedObligations();
  Future<FixedObligationModel?> addFixedObligation(FixedObligationModel model);

  Future<FixedObligationModel?> updateFixedObligation(
    FixedObligationModel model,
  );

  Future<bool> deleteFixedObligation(int id);
}
