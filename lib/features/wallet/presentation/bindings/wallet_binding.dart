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
    // // تعليق: إعداد وحقن جميع التبعيات المطلوبة لعمل وحدة المحافظ بترتيب صحيح

    // 1. Datasource (Singleton)
    Get.lazyPut<WalletLocalDatasource>(() => WalletLocalDatasourceImpl());

    // 2. Repository
    Get.lazyPut<WalletRepository>(
      () => WalletRepositoryImpl(localDatasource: Get.find()),
    );

    // 3. Use Cases
    Get.lazyPut(() => GetWalletsUseCase(Get.find()));
    Get.lazyPut(() => AddWalletUseCase(Get.find()));

    // 4. Controller
    Get.lazyPut(
      () => WalletController(
        getWalletsUseCase: Get.find(),
        addWalletUseCase: Get.find(),
      ),
    );
  }
}
