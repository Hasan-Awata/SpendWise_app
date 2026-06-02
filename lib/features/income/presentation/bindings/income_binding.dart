import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/core/network/network_service.dart';
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
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    // ---------------------------------------------------------------------
    // 1. Data Sources (مصادر البيانات) - حقن دائم لضمان استقرار الاتصالات
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<IncomeRemoteDatasource>()) {
      Get.put<IncomeRemoteDatasource>(
        IncomeRemoteDatasourceImpl(network: Get.find<NetworkService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<IncomeLocalDataSource>()) {
      Get.put<IncomeLocalDataSource>(
        IncomeLocalDataSourceImpl(Get.find<Isar>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 2. Repository (المستودع)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<IncomeRepository>()) {
      Get.put<IncomeRepository>(
        IncomeRepositoryImpl(
          localDataSource: Get.find<IncomeLocalDataSource>(),
          syncQueueRepository: Get.find<SyncQueueRepository>(),

          remote: Get.find<IncomeRemoteDatasource>(),
        ),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 3. UseCases (حالات الاستخدام)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<AddIncomeUsecase>()) {
      Get.put(AddIncomeUsecase(Get.find<IncomeRepository>()), permanent: true);
    }
    if (!Get.isRegistered<GetIncomesUsecase>()) {
      Get.put(GetIncomesUsecase(Get.find<IncomeRepository>()), permanent: true);
    }
    if (!Get.isRegistered<UpdateIncomeUseCase>()) {
      Get.put(
        UpdateIncomeUseCase(Get.find<IncomeRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<DeleteIncomeUseCase>()) {
      Get.put(
        DeleteIncomeUseCase(Get.find<IncomeRepository>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 4. Controllers (المتحكمات) -> تم تحويلها إلى lazyPut مع دعم الـ fenix
    // ---------------------------------------------------------------------

    // متحكم قائمة الإيرادات الرئيسي
    Get.lazyPut<IncomesListController>(
      () => IncomesListController(
        getIncomesUseCase: Get.find<GetIncomesUsecase>(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
      ),
      fenix: true,
    );

    // متحكم إضافة إيراد جديد
    Get.lazyPut<AddIncomeController>(
      () => AddIncomeController(
        addIncomeUseCase: Get.find<AddIncomeUsecase>(),
        walletsListController: Get.find(),
        tagController: Get.find(),
        incomesListController: Get.find<IncomesListController>(),
        tagActionController: Get.find<TagActionController>(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
        updateWalletController: Get.find<UpdateWalletController>(),
      ),
      fenix: true,
    );

    // متحكم تعديل الإيرادات
    Get.lazyPut<UpdateIncomeController>(
      () => UpdateIncomeController(
        updateIncomeUseCase: Get.find<UpdateIncomeUseCase>(),
        incomesListController: Get.find<IncomesListController>(),
      ),
      fenix: true,
    );

    // متحكم حذف الإيرادات
    Get.lazyPut<DeleteIncomeController>(
      () => DeleteIncomeController(
        deleteIncomeUseCase: Get.find<DeleteIncomeUseCase>(),
        incomesListController: Get.find<IncomesListController>(),
      ),
      fenix: true,
    );
  }
}
