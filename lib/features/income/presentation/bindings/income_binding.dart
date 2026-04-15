import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource_impl.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/data/repositories/income_repository_impl.dart';
import 'package:spendwise/features/income/domain/usecases/add_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/delete_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/get_all_local_incomes_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/get_incomes_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/update_income_usecase.dart';
import 'package:spendwise/features/income/presentation/manager/add_income_controller.dart';
import 'package:spendwise/features/income/presentation/manager/delete_income_controller.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/income/presentation/manager/update_income_controller.dart';

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IncomeRemoteDatasource>()) {
      Get.lazyPut<IncomeRemoteDatasource>(
        () => IncomeRemoteDatasourceImpl(dio: Get.find<Dio>()),
      );
    }
    if (!Get.isRegistered<IncomeLocalDataSource>()) {
      Get.lazyPut<IncomeLocalDataSource>(() => IncomeLocalDataSourceImpl());
    }
    if (!Get.isRegistered<IncomeRepository>()) {
      Get.lazyPut<IncomeRepository>(
        () => IncomeRepositoryImpl(
          localDataSource: Get.find<IncomeLocalDataSource>(),
          remoteDatasource: Get.find<IncomeRemoteDatasource>(),
        ),
      );
    }
    if (!Get.isRegistered<AddIncomeUsecase>()) {
      Get.lazyPut(() => AddIncomeUsecase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<GetIncomesUsecase>()) {
      Get.lazyPut(() => GetIncomesUsecase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<GetAllLocalIncomesUsecase>()) {
      Get.lazyPut(
        () => GetAllLocalIncomesUsecase(Get.find<IncomeRepository>()),
      );
    }
    if (!Get.isRegistered<UpdateIncomeUseCase>()) {
      Get.lazyPut(() => UpdateIncomeUseCase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<DeleteIncomeUseCase>()) {
      Get.lazyPut(() => DeleteIncomeUseCase(Get.find<IncomeRepository>()));
    }

    if (!Get.isRegistered<IncomesListController>()) {
      Get.lazyPut(
        () => IncomesListController(
          getIncomesUseCase: Get.find(),
          getAllLocalIncomesUsecase: Get.find(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AddIncomeController>()) {
      Get.lazyPut(
        () => AddIncomeController(
          addIncomeUseCase: Get.find(),
          walletsListController: Get.find(),
          tagController: Get.find(),
          incomesListController: Get.find(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<UpdateIncomeController>()) {
      Get.lazyPut(
        () => UpdateIncomeController(
          updateIncomeUseCase: Get.find(),
          incomesListController: Get.find(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<DeleteIncomeController>()) {
      Get.lazyPut(
        () => DeleteIncomeController(
          deleteIncomeUseCase: Get.find(),
          incomesListController: Get.find(),
        ),
        fenix: true,
      );
    }
  }
}
