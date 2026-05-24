import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/transaction/domain/repositories/transaction_repository.dart';

import '../entities/transaction_entity.dart';

class GetTransactionsUseCase {
  final ITransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, PagedResponse<TransactionEntity>>>
  getTransactionsByUser(int userId, PageRequest page) async {
    return await repository.getTransactionsByUser(userId, page);
  }
}
