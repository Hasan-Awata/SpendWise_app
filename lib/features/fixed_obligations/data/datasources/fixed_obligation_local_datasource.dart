import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';

abstract class FixedObligationLocalDataSource {
  FixedObligationLocalDataSource();

  Future<List<FixedObligationModel>> getFixedObligations();
  Future<void> saveFixedObligation(FixedObligationModel model);
  Future<void> saveAll(List<FixedObligationModel> models);
  Future<void> deleteFixedObligation(int isarId);
  Future<FixedObligationModel?> getById(int id);
  Future<FixedObligationModel?> getFixedObligationByIsarId(int isarId);
  Future<void> clear();
}
