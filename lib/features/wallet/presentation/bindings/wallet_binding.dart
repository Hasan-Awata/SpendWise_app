import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/core/network/network_service.dart';
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
    // 1. LOCAL SERVICES & DATASOURCES (الحقن الدائم والمستقر)
    // =====================================================

    if (!Get.isRegistered<CurrencyLocal>()) {
      Get.put<CurrencyLocal>(CurrencyLocal(Get.find<Isar>()), permanent: true);
    }

    if (!Get.isRegistered<WalletRemoteDatasource>()) {
      Get.put<WalletRemoteDatasource>(
        WalletRemoteDatasourceImpl(network: Get.find<NetworkService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<WalletLocalDatasource>()) {
      Get.put<WalletLocalDatasource>(
        WalletLocalDatasourceImpl(Get.find<Isar>()),
        permanent: true,
      );
    }

    // =====================================================
    // 2. REPOSITORIES
    // =====================================================

    if (!Get.isRegistered<CurrencyRepository>()) {
      Get.put<CurrencyRepository>(
        CurrencyRepositoryImpl(Get.find<CurrencyLocal>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<WalletRepository>()) {
      Get.put<WalletRepository>(
        WalletRepositoryImpl(
          remote: Get.find(),
          local: Get.find(),
          currencyRepository: Get.find(),
          syncQueueRepository: Get.find<SyncQueueRepository>(),
        ),
        permanent: true,
      );
    }

    // =====================================================
    // 3. USE CASES
    // =====================================================

    if (!Get.isRegistered<GetMyWalletsUseCase>()) {
      Get.put(GetMyWalletsUseCase(Get.find()), permanent: true);
    }
    if (!Get.isRegistered<AddWalletUseCase>()) {
      Get.put(AddWalletUseCase(Get.find()), permanent: true);
    }
    if (!Get.isRegistered<UpdateWalletUseCase>()) {
      Get.put(UpdateWalletUseCase(Get.find()), permanent: true);
    }
    if (!Get.isRegistered<DeleteWalletUseCase>()) {
      Get.put(DeleteWalletUseCase(Get.find()), permanent: true);
    }

    // =====================================================
    // 4. CONTROLLERS (تحويل كامل لـ lazyPut + fenix لمرونة الاستدعاء)
    // =====================================================

    // متحكم قائمة المحافظ الرئيسي
    Get.lazyPut<WalletsListController>(
      () => WalletsListController(getMyWalletsUseCase: Get.find()),
      fenix: true,
    );

    // متحكم إضافة محفظة جديدة
    Get.lazyPut<AddWalletController>(
      () => AddWalletController(
        addWalletUseCase: Get.find(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
        walletsListController: Get.find<WalletsListController>(),
      ),
      fenix: true,
    );

    // متحكم حذف محفظة
    Get.lazyPut<DeleteWalletController>(
      () => DeleteWalletController(
        deleteWalletUseCase: Get.find(),
        walletsListController: Get.find<WalletsListController>(),
        getTransactionsUseCase: Get.find(),
        userIdUsecase: Get.find(),
      ),
      fenix: true,
    );

    // متحكم تعديل بيانات المحفظة
    Get.lazyPut<UpdateWalletController>(
      () => UpdateWalletController(
        updateWalletUseCase: Get.find(),
        walletsListController: Get.find<WalletsListController>(),
      ),
      fenix: true,
    );
  }
}
