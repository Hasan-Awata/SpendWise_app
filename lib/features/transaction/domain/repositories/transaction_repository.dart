import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

import '../entities/transaction_entity.dart';

abstract class ITransactionRepository {
  Future<Either<Failure, PagedResponse<TransactionEntity>>>
  getTransactionsByUser(int userId, PageRequest page);
}
