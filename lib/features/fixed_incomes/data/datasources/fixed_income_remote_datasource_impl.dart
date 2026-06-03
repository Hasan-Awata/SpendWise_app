import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_remote_datasource.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';

class FixedIncomeRemoteDataSourceImpl implements FixedIncomeRemoteDataSource {
  final NetworkService network;

  FixedIncomeRemoteDataSourceImpl({required this.network});

  // =========================
  // GET ALL IncomeS
  // =========================
  @override
  Future<List<FixedIncomeModel>?> getFixedIncomes() async {
    final result = await network.request(
      endpoint: ApiEndpoints
          .fixedIncomes, // تأكد من إضافة هذا المسار في ملف endpoints
      method: "GET",
    );

    if (result == null) return [];

    return (result as List)
        .map((json) => FixedIncomeModel.fromJson(json))
        .toList();
  }

  // =========================
  // ADD Income
  // =========================
  @override
  Future<FixedIncomeModel?> addFixedIncome(FixedIncomeModel model) async {
    final result = await network.request(
      endpoint: ApiEndpoints.fixedIncomes,
      method: "POST",
      body: model.toJson(),
    );

    return FixedIncomeModel.fromJson(result);
  }

  // =========================
  // UPDATE Income
  // =========================
  @override
  Future<FixedIncomeModel?> updateFixedIncome(FixedIncomeModel model) async {
    final result = await network.request(
      endpoint: "${ApiEndpoints.fixedIncomes}/${model.fixedIncomeId}",
      method: "PATCH",
      body: model.toJson(),
    );
    return FixedIncomeModel.fromJson(result);
  }

  // =========================
  // DELETE Income
  // =========================
  @override
  Future<bool> deleteFixedIncome(int id) async {
    try {
      await network.request(
        endpoint: "${ApiEndpoints.fixedIncomes}/$id",
        method: "DELETE",
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
