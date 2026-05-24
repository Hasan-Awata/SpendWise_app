// lib/features/transaction/presentation/bindings/transaction_binding.dart
// TransactionBinding: Dynamically injects repository, datasources, and usecase contexts into GetX memory

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:spendwise/core/services/init_isar.dart';
import 'package:spendwise/features/transaction/data/datasources/transaction_local_datasource.dart';
import 'package:spendwise/features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'package:spendwise/features/transaction/domain/repositories/transaction_repository.dart'
    show ITransactionRepository;

import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../manager/transaction_controller.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => http.Client());
    Get.lazyPut<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(client: Get.find()),
    );
    Get.lazyPut<TransactionLocalDataSource>(
      () => TransactionLocalDataSourceImpl(isar: InitIsar.isar!),
    );
    Get.lazyPut<ITransactionRepository>(
      () => TransactionRepositoryImpl(
        remoteDataSource: Get.find(),

        localDataSource: Get.find(),
      ),
    );
    Get.lazyPut(() => GetTransactionsUseCase(Get.find()));
    Get.put(TransactionController(getTransactionsUseCase: Get.find()));
  }
}
