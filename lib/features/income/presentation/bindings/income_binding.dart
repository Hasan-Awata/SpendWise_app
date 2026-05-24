import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
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
import 'package:spendwise/features/income/presentation/manager/add_income_controller.dart';
import 'package:spendwise/features/income/presentation/manager/delete_income_controller.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/income/presentation/manager/update_income_controller.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_action_controller.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Sources (مصادر البيانات)
    if (!Get.isRegistered<IncomeRemoteDatasource>()) {
      Get.lazyPut<IncomeRemoteDatasource>(
        () =>
            // IncomeRemoteDatasourceImpl(dio: Get.find<Dio>()),
            IncomeRemoteDatasourceImpl(client: http.Client()),
      );
    }
    if (!Get.isRegistered<IncomeLocalDataSource>()) {
      Get.lazyPut<IncomeLocalDataSource>(
        () => IncomeLocalDataSourceImpl(Get.find<Isar>()),
      );
    }

    // 2. Repository (المستودع)
    if (!Get.isRegistered<IncomeRepository>()) {
      Get.lazyPut<IncomeRepository>(
        () => IncomeRepositoryImpl(
          localDataSource: Get.find<IncomeLocalDataSource>(),
          syncQueueRepository: Get.find<SyncQueueRepository>(),
          walletLocalDatasource: Get.find<WalletLocalDatasource>(),
          currencyLocal: Get.find<CurrencyLocal>(),
          remote: Get.find<IncomeRemoteDatasource>(),
        ),
      );
    }

    // 3. UseCases (حالات الاستخدام)
    if (!Get.isRegistered<AddIncomeUsecase>()) {
      Get.lazyPut(() => AddIncomeUsecase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<GetIncomesUsecase>()) {
      Get.lazyPut(() => GetIncomesUsecase(Get.find<IncomeRepository>()));
    }
    // if (!Get.isRegistered<GetAllLocalIncomesUsecase>()) {
    //   Get.lazyPut(
    //     () => GetAllLocalIncomesUsecase(Get.find<IncomeRepository>()),
    //   );
    // }
    if (!Get.isRegistered<UpdateIncomeUseCase>()) {
      Get.lazyPut(() => UpdateIncomeUseCase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<DeleteIncomeUseCase>()) {
      Get.lazyPut(() => DeleteIncomeUseCase(Get.find<IncomeRepository>()));
    }
    // if (!Get.isRegistered<SyncPendingIncomesUsecase>()) {
    //   Get.lazyPut(()=>SyncPendingIncomesUsecase(Get.find()));
    // }

    // 4. Controllers (المتحكمات)
    // تم تحويلها إلى Get.lazyPut لضمان عملها فور الدخول إلى واجهة الدخل
    if (!Get.isRegistered<IncomesListController>()) {
      Get.lazyPut(
        () => IncomesListController(
          getIncomesUseCase: Get.find<GetIncomesUsecase>(),

          // getAllLocalIncomesUsecase: Get.find<GetAllLocalIncomesUsecase>(),
          userIdUsecase: Get.find<GetUserIdUsecase>(),
        ),
      );
    }

    if (!Get.isRegistered<AddIncomeController>()) {
      Get.lazyPut(
        () => AddIncomeController(
          addIncomeUseCase: Get.find<AddIncomeUsecase>(),
          walletsListController: Get.find(),
          tagController: Get.find(),
          incomesListController: Get.find<IncomesListController>(),
          tagActionController: Get.find<TagActionController>(),
          userIdUsecase: Get.find<GetUserIdUsecase>(),
          updateWalletController: Get.find<UpdateWalletController>(),
        ),
      );
    }

    if (!Get.isRegistered<UpdateIncomeController>()) {
      Get.lazyPut(
        () => UpdateIncomeController(
          updateIncomeUseCase: Get.find<UpdateIncomeUseCase>(),
          incomesListController: Get.find<IncomesListController>(),
        ),
      );
    }

    if (!Get.isRegistered<DeleteIncomeController>()) {
      Get.lazyPut(
        () => DeleteIncomeController(
          deleteIncomeUseCase: Get.find<DeleteIncomeUseCase>(),
          incomesListController: Get.find<IncomesListController>(),
        ),
      );
    }
  }
}
