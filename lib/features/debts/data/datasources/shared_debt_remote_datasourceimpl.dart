import 'dart:convert';

import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/debts/data/datasources/shared_debt_remote_datasource.dart';
import 'package:spendwise/features/debts/data/models/shared_debt_model.dart';

class SharedDebtRemoteDatasourceImpl implements SharedDebtRemoteDatasource {
  final NetworkService network;

  SharedDebtRemoteDatasourceImpl({required this.network});

  // Base route from backend: /api/Shared_Debt

  final String base = ApiEndpoints.sharedDebt;
  // الأفضل يكون: "/api/Shared_Debt"

  // =========================
  // GET ALL DEBTS FOR USER
  // =========================
  @override
  Future<List<SharedDebtModel>> getMyDebts(int userId) async {
    final result = await network.request(
      endpoint: "$base/GetAllDebtsForUser",
      method: "GET",
    );

    return (result as List).map((e) => SharedDebtModel.fromJson(e)).toList();
  }

  // =========================
  // GET BY ID
  // =========================
  Future<SharedDebtModel> getDebtById(int id) async {
    final result = await network.request(
      endpoint: "$base/GetDebtByID/$id",
      method: "GET",
    );

    return SharedDebtModel.fromJson(result);
  }

  // =========================
  // GET BY TITLE
  // =========================
  Future<List<SharedDebtModel>> getDebtByTitle(String title) async {
    final result = await network.request(
      endpoint: "$base/GetDebtByTitle/$title",
      method: "GET",
    );

    return (result as List).map((e) => SharedDebtModel.fromJson(e)).toList();
  }

  // =========================
  // GET DEBTS OWED TO USER
  // =========================
  Future<List<SharedDebtModel>> getDebtsOwedToUser() async {
    final result = await network.request(
      endpoint: "$base/GetDebtsOwedToUser",
      method: "GET",
    );

    return (result as List).map((e) => SharedDebtModel.fromJson(e)).toList();
  }

  // =========================
  // GET DEBTS I HAVE TO PAY
  // =========================
  Future<List<SharedDebtModel>> getDebtsIHaveToPay() async {
    final result = await network.request(
      endpoint: "$base/GetDebtsIHaveToPay",
      method: "GET",
    );

    return (result as List).map((e) => SharedDebtModel.fromJson(e)).toList();
  }

  // =========================
  // ADD DEBT
  // =========================
  @override
  Future<SharedDebtModel> addDebt(SharedDebtModel debt) async {
    final result = await network.request(
      endpoint: "$base/AddDebt",
      method: "POST",
      body: debt.toJson(),
    );

    return SharedDebtModel.fromJson(jsonDecode(result));
  }

  // =========================
  // UPDATE DEBT
  // =========================
  @override
  Future<void> updateDebt(SharedDebtModel debt) async {
    await network.request(
      endpoint: "$base/UpdateDebt/${debt.debtId}",
      method: "PATCH",
      body: debt.toJson(),
    );
  }

  // =========================
  // DELETE BY ID
  // =========================
  @override
  Future<bool> deleteDebt(SharedDebtModel debt) async {
    if (debt.debtId == null) return false;

    await network.request(
      endpoint: "$base/DeleteDebt/${debt.debtId}",
      method: "DELETE",
    );

    return true;
  }

  // =========================
  // DELETE BY TITLE
  // =========================
  Future<void> deleteDebtByTitle(String title) async {
    await network.request(
      endpoint: "$base/DeleteDebtByTitle/$title",
      method: "DELETE",
    );
  }

  // =========================
  // CHECK EXISTS
  // =========================
  Future<bool> checkDebtExists(int id) async {
    final result = await network.request(
      endpoint: "$base/CheckDebtExists/$id",
      method: "GET",
    );

    return result == true;
  }

  // =========================
  // RETURN DEBT AMOUNT
  // =========================
  Future<void> returnDebtAmount(int debtId, dynamic dto) async {
    await network.request(
      endpoint: "$base/ReturnDebtAmount/$debtId",
      method: "POST",
      body: dto,
    );
  }

  // =========================
  // ACCEPT DEBT
  // =========================
  Future<void> acceptDebt(int debtId, dynamic dto) async {
    await network.request(
      endpoint: "$base/AcceptDebt/$debtId",
      method: "PUT",
      body: dto,
    );
  }

  // =========================
  // REFUSE DEBT
  // =========================
  Future<void> refuseDebt(int debtId) async {
    await network.request(
      endpoint: "$base/RefuseDebt/$debtId",
      method: "PATCH",
    );
  }
}
