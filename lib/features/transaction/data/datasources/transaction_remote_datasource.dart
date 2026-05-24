// lib/features/transaction/data/datasources/transaction_remote_data_source.dart
// TransactionRemoteDataSourceImpl: Dispatches networking payloads to sync global server ledger states using core page request tokens

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
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

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final http.Client client;

  TransactionRemoteDataSourceImpl({required this.client});

  @override
  Future<PagedResponse<TransactionModel>?> getMyTransactions(
    int userId,
    PageRequest page,
  ) async {
    // Build URL with pagination and userId query parameters dynamically matching [HttpGet] API criteria
    final url = Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.transactions}")
        .replace(
          queryParameters: {
            'UserId': userId.toString(),
            'PageNumber': page.pageNumber.toString(),
            'PageSize': page.pageSize.toString(),
          },
        );

    final headers = await ApiEndpoints().getHeaders();
    final response = await client.get(url, headers: headers);
    print(
      "transactions is ->>>> ${response.body} , status code ${response.statusCode}",
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decodedData = jsonDecode(response.body);
      return PagedResponse<TransactionModel>.fromJson(
        decodedData,
        (json) => TransactionModel.fromJson(json),
      );
    } else {
      throw Exception("فشل جلب المعاملات من السيرفر: ${response.statusCode}");
    }
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.transactions}",
    );
    final headers = await ApiEndpoints().getHeaders();
    final body = jsonEncode(transaction.toJson());

    final response = await client.post(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return TransactionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("فشل إضافة المعاملة المالية: ${response.body}");
    }
  }

  @override
  Future<TransactionModel?> updateTransaction(
    TransactionModel transaction,
  ) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.transactions}/${transaction.id}",
    );
    final headers = await ApiEndpoints().getHeaders();
    final body = jsonEncode(transaction.toJson());

    final response = await client.patch(url, headers: headers, body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return transaction;
      return TransactionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("فشل تحديث المعاملة المالية: ${response.statusCode}");
    }
  }

  @override
  Future<bool> deleteTransaction(TransactionModel transaction) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.transactions}/${transaction.id}",
    );
    final headers = await ApiEndpoints().getHeaders();

    final response = await client.delete(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      return false;
    }
  }
}
