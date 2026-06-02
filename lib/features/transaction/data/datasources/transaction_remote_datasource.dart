import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<PagedResponse<TransactionModel>?> getMyTransactions(
    int userId,
    PageRequest page,
  );

  Future<TransactionModel> addTransaction(TransactionModel transaction);

  Future<TransactionModel?> updateTransaction(TransactionModel transaction);

  Future<bool> deleteTransaction(TransactionModel transaction);
}

class TransactionRemoteDataSourceImpl
    implements TransactionRemoteDataSource {
  final NetworkService network;

  TransactionRemoteDataSourceImpl({required this.network});

  // =========================
  // GET TRANSACTIONS
  // =========================
  @override
  Future<PagedResponse<TransactionModel>?> getMyTransactions(
    int userId,
    PageRequest page,
  ) async {
    final result = await network.request(
      endpoint: ApiEndpoints.transactions,
      method: "GET",
      queryParameters: {
        "UserId": userId,
        "PageNumber": page.pageNumber,
        "PageSize": page.pageSize,
      },
    );

    final List list = result is Map && result["data"] is List
        ? result["data"]
        : result;

    final transactions = list
        .map((e) => TransactionModel.fromJson(e))
        .toList();

    return PagedResponse<TransactionModel>(
      data: transactions,
      totalRecords: transactions.length,
      pageNumber: page.pageNumber,
      pageSize: page.pageSize,
      totalPages: 1,
    );
  }

  // =========================
  // ADD TRANSACTION
  // =========================
  @override
  Future<TransactionModel> addTransaction(
    TransactionModel transaction,
  ) async {
    final result = await network.request(
      endpoint: ApiEndpoints.transactions,
      method: "POST",
      body: transaction.toJson(),
    );

    return TransactionModel.fromJson(result);
  }

  // =========================
  // UPDATE TRANSACTION
  // =========================
  @override
  Future<TransactionModel?> updateTransaction(
    TransactionModel transaction,
  ) async {
    final result = await network.request(
      endpoint:
          "${ApiEndpoints.transactions}/${transaction.id}",
      method: "PATCH",
      body: transaction.toJson(),
    );

    return TransactionModel.fromJson(result);
  }

  // =========================
  // DELETE TRANSACTION
  // =========================
  @override
  Future<bool> deleteTransaction(TransactionModel transaction) async {
    try {
      await network.request(
        endpoint:
            "${ApiEndpoints.transactions}/${transaction.id}",
        method: "DELETE",
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}