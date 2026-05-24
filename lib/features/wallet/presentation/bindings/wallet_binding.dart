import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/repositories/currency_repository.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/repositories/currency_repository_impl.dart';
import 'package:spendwise/features/wallet/domain/repositories/wallet_repository_impl.dart';
import 'package:spendwise/features/wallet/domain/usecases/add_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/delete_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/update_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/add_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/delete_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class WalletBinding implements Bindings {
  @override
  void dependencies() {
    // =====================================================
    // LOCAL SERVICES
    // =====================================================

    Get.lazyPut<CurrencyLocal>(
      () => CurrencyLocal(Get.find<Isar>()),
      fenix: true,
    );

    // =====================================================
    // DATASOURCES
    // =====================================================

    Get.lazyPut<WalletRemoteDatasource>(
      () => WalletRemoteDatasourceImpl(client: http.Client()),
      fenix: true,
    );

    Get.lazyPut<WalletLocalDatasource>(
      () => WalletLocalDatasourceImpl(Get.find<Isar>()),
      fenix: true,
    );

    // =====================================================
    // REPOSITORIES
    // =====================================================

    Get.lazyPut<CurrencyRepository>(
      () => CurrencyRepositoryImpl(Get.find<CurrencyLocal>()),
      fenix: true,
    );

    Get.lazyPut<WalletRepository>(
      () => WalletRepositoryImpl(
        remote: Get.find(),
        local: Get.find(),
        currencyRepository: Get.find(),
        syncQueueRepository: Get.find<SyncQueueRepository>(),
      ),
      fenix: true,
    );

    // =====================================================
    // USE CASES
    // =====================================================

    Get.lazyPut(() => GetMyWalletsUseCase(Get.find()), fenix: true);

    Get.lazyPut(() => AddWalletUseCase(Get.find()), fenix: true);

    Get.lazyPut(() => UpdateWalletUseCase(Get.find()), fenix: true);

    Get.lazyPut(() => DeleteWalletUseCase(Get.find()), fenix: true);

    // Get.lazyPut(() => GetAllWalletsLocalUseCase(Get.find()), fenix: true);

    // =====================================================
    // CONTROLLERS
    // =====================================================

    Get.put(
      WalletsListController(
        getMyWalletsUseCase: Get.find(),

        // getAllLocalWalletsUseCase: Get.find(),
      ),
    );

    Get.lazyPut(
      () => AddWalletController(
        addWalletUseCase: Get.find(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
        walletsListController: Get.find<WalletsListController>(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => DeleteWalletController(
        deleteWalletUseCase: Get.find(),
        walletsListController: Get.find<WalletsListController>(),
      ),

      fenix: true,
    );

    Get.lazyPut(
      () => UpdateWalletController(
        updateWalletUseCase: Get.find(),
        walletsListController: Get.find<WalletsListController>(),
      ),
      fenix: true,
    );
  }
}
