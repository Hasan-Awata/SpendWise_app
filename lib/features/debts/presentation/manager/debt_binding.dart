import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_by_user_name_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/debts/data/datasources/shared_debt_local_datasource.dart';
import 'package:spendwise/features/debts/data/datasources/shared_debt_local_datasource_impl.dart';
import 'package:spendwise/features/debts/data/datasources/shared_debt_remote_datasource.dart';
import 'package:spendwise/features/debts/data/datasources/shared_debt_remote_datasourceimpl.dart';
import 'package:spendwise/features/debts/data/repositories/shared_debt_repository.dart';
import 'package:spendwise/features/debts/domain/repositories/shared_debt_repository_impl.dart';
import 'package:spendwise/features/debts/domain/usecases/add_debt_usecase.dart';
import 'package:spendwise/features/debts/domain/usecases/delete_debt_usecase.dart';
import 'package:spendwise/features/debts/domain/usecases/get_debts_usecase.dart';
import 'package:spendwise/features/debts/domain/usecases/update_debt_usecase.dart';
import 'package:spendwise/features/debts/presentation/manager/add_debt_controller.dart';
import 'package:spendwise/features/debts/presentation/manager/debts_list_controller.dart';
import 'package:spendwise/features/debts/presentation/manager/delete_debt_controller.dart';
import 'package:spendwise/features/debts/presentation/manager/update_debt_controller.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class SharedDebtBinding extends Bindings {
  @override
  void dependencies() {
    // ---------------------------------------------------------------------
    // Data Sources
    // ---------------------------------------------------------------------

    if (!Get.isRegistered<SharedDebtRemoteDatasource>()) {
      Get.put<SharedDebtRemoteDatasource>(
        SharedDebtRemoteDatasourceImpl(network: Get.find<NetworkService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<SharedDebtLocalDataSource>()) {
      Get.put<SharedDebtLocalDataSource>(
        SharedDebtLocalDataSourceImpl(Get.find<Isar>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // Repository
    // ---------------------------------------------------------------------

    if (!Get.isRegistered<SharedDebtRepository>()) {
      Get.put<SharedDebtRepository>(
        SharedDebtRepositoryImpl(
          localDataSource: Get.find<SharedDebtLocalDataSource>(),
          remote: Get.find<SharedDebtRemoteDatasource>(),
          syncQueueRepository: Get.find<SyncQueueRepository>(),
        ),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // UseCases
    // ---------------------------------------------------------------------

    if (!Get.isRegistered<AddDebtUseCase>()) {
      Get.put(
        AddDebtUseCase(Get.find<SharedDebtRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<GetDebtsUseCase>()) {
      Get.put(
        GetDebtsUseCase(Get.find<SharedDebtRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<UpdateDebtUseCase>()) {
      Get.put(
        UpdateDebtUseCase(Get.find<SharedDebtRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<DeleteDebtUseCase>()) {
      Get.put(
        DeleteDebtUseCase(Get.find<SharedDebtRepository>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // Controllers
    // ---------------------------------------------------------------------

    Get.lazyPut<DebtsListController>(
      () => DebtsListController(
        getDebtsUseCase: Get.find<GetDebtsUseCase>(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AddDebtController>(
      () => AddDebtController(
        addDebtUseCase: Get.find<AddDebtUseCase>(),
        debtsListController: Get.find<DebtsListController>(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
        walletsListController: Get.find<WalletsListController>(),
        getUserByUsernameUseCase: Get.find<GetUserByUsernameUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UpdateDebtController>(
      () => UpdateDebtController(
        updateDebtUseCase: Get.find<UpdateDebtUseCase>(),
        debtsListController: Get.find<DebtsListController>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DeleteDebtController>(
      () => DeleteDebtController(
        deleteDebtUseCase: Get.find<DeleteDebtUseCase>(),
        debtsListController: Get.find<DebtsListController>(),
      ),
      fenix: true,
    );
  }
}
