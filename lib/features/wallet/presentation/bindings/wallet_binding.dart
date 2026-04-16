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
import 'package:spendwise/features/wallet/domain/usecases/sync_wallets_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/update_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/add_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/delete_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

// This binding class manages the immediate injection of wallet-related dependencies using Get.put
class WalletBinding implements Bindings {
  @override
  void dependencies() {
    // Data Sources
    if (!Get.isRegistered<WalletRemoteDatasource>()) {
      Get.put<WalletRemoteDatasource>(
        WalletRemoteDatasourceImpl(dio: Get.find<Dio>()),
      );
    }

    if (!Get.isRegistered<WalletLocalDatasource>()) {
      Get.put<WalletLocalDatasource>(WalletLocalDatasourceImpl());
    }

    // Repository
    if (!Get.isRegistered<WalletRepository>()) {
      Get.put<WalletRepository>(
        WalletRepositoryImpl(
          remoteDatasource: Get.find(),
          localDatasource: Get.find(),
        ),
      );
    }

    // Use Cases
    Get.put(GetMyWalletsUseCase(Get.find()));
    Get.put(AddWalletUseCase(Get.find()));
    Get.put(UpdateWalletUseCase(Get.find()));
    Get.put(DeleteWalletUseCase(Get.find()));
    Get.put(SyncWalletsUseCase(Get.find()));

    // Controllers
    if (!Get.isRegistered<WalletsListController>()) {
      Get.put(
        WalletsListController(
          getMyWalletsUseCase: Get.find(),
          syncWalletsUseCase: Get.find(),
        ),
      );
    }

    if (!Get.isRegistered<AddWalletController>()) {
      Get.put(AddWalletController(addWalletUseCase: Get.find()));
    }

    if (!Get.isRegistered<DeleteWalletController>()) {
      Get.put(DeleteWalletController(deleteWalletUseCase: Get.find()));
    }

    if (!Get.isRegistered<UpdateWalletController>()) {
      Get.put(UpdateWalletController(updateWalletUseCase: Get.find()));
    }
  }
}
