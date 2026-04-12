import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource_impl.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/data/repositories/income_repository_impl.dart';
import 'package:spendwise/features/income/domain/usecases/add_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/delete_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/get_incomes_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/update_income_usecase.dart';
import 'package:spendwise/features/income/presentation/manager/income_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';

//binding مهمته الأساسية هي إعداد كل ما تحتاجه الشاشة من (Controllers, Use Cases, Repositories)

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeRemoteDatasource>(
      () => IncomeRemoteDatasourceImpl(dio: Get.find<Dio>()),
    );
    Get.lazyPut<IncomeLocalDataSource>(() {
      final datasource = IncomeLocalDataSourceImpl();
      return datasource;
    });
    Get.lazyPut<IncomeRepository>(
      () => IncomeRepositoryImpl(
        localDataSource: Get.find<IncomeLocalDataSource>(),
        remoteDatasource: Get.find<IncomeRemoteDatasource>(),
      ),
    );
    Get.lazyPut(() => AddIncomeUsecase(Get.find<IncomeRepository>()));
    Get.lazyPut(() => GetIncomesUsecase(Get.find<IncomeRepository>()));
    Get.lazyPut(() => UpdateIncomeUseCase(Get.find<IncomeRepository>()));
    Get.lazyPut(() => DeleteIncomeUseCase(Get.find<IncomeRepository>()));
    Get.put(
      IncomeController(
        addIncomeUseCase: Get.find<AddIncomeUsecase>(),
        getIncomesUseCase: Get.find<GetIncomesUsecase>(),
        walletController: Get.find<WalletController>(),
        tagController: Get.find<TagController>(),
        updateIncomeUseCase: Get.find<UpdateIncomeUseCase>(),
        deleteIncomeUseCase: Get.find<DeleteIncomeUseCase>(),
      ),
    );
  }
}
