import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/fixed_obligations/data/datasources/fixed_obligation_remote_datasource.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';

class FixedObligationRemoteDataSourceImpl
    implements FixedObligationRemoteDataSource {
  final NetworkService network;

  FixedObligationRemoteDataSourceImpl({required this.network});

  // =========================
  // GET ALL OBLIGATIONS
  // =========================
  @override
  Future<List<FixedObligationModel>?> getFixedObligations() async {
    final result = await network.request(
      endpoint: ApiEndpoints
          .fixedObligations, // تأكد من إضافة هذا المسار في ملف endpoints
      method: "GET",
    );

    if (result == null) return [];

    return (result as List)
        .map((json) => FixedObligationModel.fromJson(json))
        .toList();
  }

  // =========================
  // ADD OBLIGATION
  // =========================
  @override
  Future<FixedObligationModel?> addFixedObligation(
    FixedObligationModel model,
  ) async {
    final result = await network.request(
      endpoint: ApiEndpoints.fixedObligations,
      method: "POST",
      body: model.toJson(),
    );

    return FixedObligationModel.fromJson(result);
  }

  // =========================
  // UPDATE OBLIGATION
  // =========================
  @override
  Future<FixedObligationModel?> updateFixedObligation(
    FixedObligationModel model,
  ) async {
    final result = await network.request(
      endpoint: "${ApiEndpoints.fixedObligations}/${model.id}",
      method: "PATCH",
      body: model.toJson(),
    );
    return FixedObligationModel.fromJson(result);
  }

  // =========================
  // DELETE OBLIGATION
  // =========================
  @override
  Future<bool> deleteFixedObligation(int id) async {
    try {
      await network.request(
        endpoint: "${ApiEndpoints.fixedObligations}/$id",
        method: "DELETE",
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
