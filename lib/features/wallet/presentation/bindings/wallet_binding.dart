import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/repositories/wallet_repository_impl.dart';
import 'package:spendwise/features/wallet/domain/usecases/add_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/delete_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/update_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';

class WalletBinding implements Bindings {
  @override
  void dependencies() {
    // 1. Datasources (Remote & Local)
    if (!Get.isRegistered<WalletRemoteDatasource>()) {
      Get.lazyPut<WalletRemoteDatasource>(
        () => WalletRemoteDatasourceImpl(dio: Get.find<Dio>()),
      );
    }

    if (!Get.isRegistered<WalletLocalDatasource>()) {
      Get.lazyPut<WalletLocalDatasource>(() => WalletLocalDatasourceImpl());
    }

    // 2. Repository
    if (!Get.isRegistered<WalletRepository>()) {
      Get.lazyPut<WalletRepository>(
        () => WalletRepositoryImpl(
          remoteDatasource: Get.find(),
          localDatasource: Get.find(),
        ),
      );
    }

    // 3. Use Cases
    Get.lazyPut(() => GetMyWalletsUseCase(Get.find()));
    Get.lazyPut(() => AddWalletUseCase(Get.find()));
    Get.lazyPut(() => UpdateWalletUseCase(Get.find()));
    Get.lazyPut(() => DeleteWalletUseCase(Get.find()));

    // 4. Controller
    if (!Get.isRegistered<WalletController>()) {
      Get.lazyPut(
        () => WalletController(
          getMyWalletsUseCase: Get.find(),
          addWalletUseCase: Get.find(),
          updateWalletUseCase: Get.find(),
          deleteWalletUseCase: Get.find(),
        ),
        fenix: true,
      );
    }
  }
}
