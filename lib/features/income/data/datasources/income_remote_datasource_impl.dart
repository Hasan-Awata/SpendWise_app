import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomeRemoteDatasourceImpl implements IncomeRemoteDatasource {
  final NetworkService network;

  IncomeRemoteDatasourceImpl({required this.network});

  // =========================
  // GET INCOMES
  // =========================
  @override
  Future<PagedResponse<IncomeModel>?> getMyIncomes(
    int userId,
    PageRequest page,
  ) async {
    final result = await network.request(
      endpoint: ApiEndpoints.income,
      method: "GET",
      queryParameters: {
        "UserId": userId,
        "PageNumber": page.pageNumber,
        "PageSize": page.pageSize,
      },
    );

    return PagedResponse<IncomeModel>.fromJson(
      result,
      (json) => IncomeModel.fromJson(json),
    );
  }

  // =========================
  // ADD INCOME
  // =========================
  @override
  Future<IncomeModel> addIncome(IncomeModel income) async {
    final result = await network.request(
      endpoint: ApiEndpoints.income,
      method: "POST",
      body: income.toJson(),
    );

    return IncomeModel.fromJson(result);
  }

  // =========================
  // UPDATE INCOME
  // =========================
  @override
  Future<IncomeModel> updateIncome(IncomeModel income) async {
    final result = await network.request(
      endpoint: "${ApiEndpoints.income}/${income.id}",
      method: "PATCH",
      body: income.toJson(),
    );

    return IncomeModel.fromJson(result);
  }

  // =========================
  // DELETE INCOME
  // =========================
  @override
  Future<bool> deleteIncome(IncomeModel income) async {
    if (income.id == null) return true;

    try {
      await network.request(
        endpoint: "${ApiEndpoints.income}/${income.id}",
        method: "DELETE",
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
