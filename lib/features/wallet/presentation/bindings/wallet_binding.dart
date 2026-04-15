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
import 'package:spendwise/features/wallet/presentation/manager/add_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/delete_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class WalletBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WalletRemoteDatasource>()) {
      Get.lazyPut<WalletRemoteDatasource>(
        () => WalletRemoteDatasourceImpl(dio: Get.find<Dio>()),
      );
    }

    if (!Get.isRegistered<WalletLocalDatasource>()) {
      Get.lazyPut<WalletLocalDatasource>(() => WalletLocalDatasourceImpl());
    }

    if (!Get.isRegistered<WalletRepository>()) {
      Get.lazyPut<WalletRepository>(
        () => WalletRepositoryImpl(
          remoteDatasource: Get.find(),
          localDatasource: Get.find(),
        ),
      );
    }

    Get.lazyPut(() => GetMyWalletsUseCase(Get.find()));
    Get.lazyPut(() => AddWalletUseCase(Get.find()));
    Get.lazyPut(() => UpdateWalletUseCase(Get.find()));
    Get.lazyPut(() => DeleteWalletUseCase(Get.find()));

    if (!Get.isRegistered<WalletsListController>()) {
      Get.lazyPut(
        () => WalletsListController(getMyWalletsUseCase: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AddWalletController>()) {
      Get.lazyPut(
        () => AddWalletController(addWalletUseCase: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<DeleteWalletController>()) {
      Get.lazyPut(
        () => DeleteWalletController(deleteWalletUseCase: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<UpdateWalletController>()) {
      Get.lazyPut(
        () => UpdateWalletController(updateWalletUseCase: Get.find()),
        fenix: true,
      );
    }
  }
}
