import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/repositories/wallet_repository_impl.dart';
import 'package:spendwise/features/wallet/domain/usecases/add_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/delete_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_all_wallets_local_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/sync_wallets_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/update_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/add_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/delete_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class WalletBinding implements Bindings {
  @override
  void dependencies() {
    // // تعليق: استخدام fenix: true مع lazyPut يضمن إعادة إنشاء الـ Controller إذا تم حذفه من الذاكرة واحتجناه مرة أخرى

    // 1. Data Sources (يفضل بقاؤها لخدمة المزامنة الخلفية)
    Get.lazyPut<WalletRemoteDatasource>(
      () => WalletRemoteDatasourceImpl(client: http.Client()),
      fenix: true,
    );
    Get.lazyPut<WalletLocalDatasource>(
      () => WalletLocalDatasourceImpl(),
      fenix: true,
    );

    // 2. Repository
    Get.lazyPut<WalletRepository>(
      () => WalletRepositoryImpl(
        remoteDatasource: Get.find(),
        localDatasource: Get.find(),
      ),
      fenix: true,
    );

    // 3. Use Cases (Lazy Loading)
    Get.lazyPut(() => GetMyWalletsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => AddWalletUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => UpdateWalletUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => DeleteWalletUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => SyncWalletsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetAllWalletsLocalUseCase(Get.find()), fenix: true);

    // 4. Controllers
    // يفضل استخدام lazyPut للـ Controllers لتقليل استهلاك الذاكرة عند فتح التطبيق
    Get.put(
      WalletsListController(
        getMyWalletsUseCase: Get.find(),
        syncWalletsUseCase: Get.find(),
        getAllWalletsLocalUseCase: Get.find(),
      ),
    );

    Get.lazyPut(
      () => AddWalletController(addWalletUseCase: Get.find()),
      fenix: true,
    );
    Get.lazyPut(
      () => DeleteWalletController(deleteWalletUseCase: Get.find()),
      fenix: true,
    );
    Get.lazyPut(
      () => UpdateWalletController(updateWalletUseCase: Get.find()),
      fenix: true,
    );
  }
}
