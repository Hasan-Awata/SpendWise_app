import 'package:get/get.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/repositories/wallet_repository_impl.dart';
import 'package:spendwise/features/wallet/domain/usecases/add_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';

class WalletBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WalletLocalDatasource>()) {
      Get.lazyPut<WalletLocalDatasource>(() => WalletLocalDatasourceImpl());
    }
    if (!Get.isRegistered<WalletRepository>()) {
      Get.lazyPut<WalletRepository>(
        () => WalletRepositoryImpl(localDatasource: Get.find()),
      );
    }
    if (!Get.isRegistered<GetWalletsUseCase>()) {
      Get.lazyPut(() => GetWalletsUseCase(Get.find()));
    }
    if (!Get.isRegistered<AddWalletUseCase>()) {
      Get.lazyPut(() => AddWalletUseCase(Get.find()));
    }
    if (!Get.isRegistered<WalletController>()) {
      Get.lazyPut(
        () => WalletController(
          getWalletsUseCase: Get.find(),
          addWalletUseCase: Get.find(),
        ),
        fenix: true,
      );
    }
  }
}
