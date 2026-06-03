import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_local_datasource.dart';
import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_local_datasource_impl.dart';
import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_remote_datasource.dart';
import 'package:spendwise/features/fixed_incomes/data/datasources/fixed_income_remote_datasource_impl.dart';
import 'package:spendwise/features/fixed_incomes/data/repositories/fixed_income_repository.dart';
import 'package:spendwise/features/fixed_incomes/domain/repositories/fixed_income_repository_impl.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/add_fixed_income_usecase.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/delete_fixed_income_usecase.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/get_fixed_income_usecase.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/update_fixed_income_usecases.dart';
import 'package:spendwise/features/fixed_incomes/presentation/manager/fixed_income_controller.dart';
import 'package:spendwise/features/fixed_incomes/presentation/manager/fixed_income_list_controller.dart';

class FixedIncomeBinding extends Bindings {
  @override
  void dependencies() {
    // ---------------------------------------------------------------------
    // 1. Data Sources (مصادر البيانات)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<FixedIncomeRemoteDataSource>()) {
      Get.put<FixedIncomeRemoteDataSource>(
        FixedIncomeRemoteDataSourceImpl(network: Get.find<NetworkService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<FixedIncomeLocalDataSource>()) {
      Get.put<FixedIncomeLocalDataSource>(
        FixedIncomeLocalDataSourceImpl(Get.find<Isar>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 2. Repository (المستودع)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<FixedIncomeRepository>()) {
      Get.put<FixedIncomeRepository>(
        FixedIncomeRepositoryImpl(
          localDataSource: Get.find<FixedIncomeLocalDataSource>(),
          remote: Get.find<FixedIncomeRemoteDataSource>(),
          syncQueueRepository: Get.find(),
        ),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 3. Use Cases (حالات الاستخدام)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<AddFixedIncomeUseCase>()) {
      Get.put(
        AddFixedIncomeUseCase(Get.find<FixedIncomeRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<GetFixedIncomesUseCase>()) {
      Get.put(
        GetFixedIncomesUseCase(Get.find<FixedIncomeRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<UpdateFixedIncomeUseCase>()) {
      Get.put(
        UpdateFixedIncomeUseCase(Get.find<FixedIncomeRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<DeleteFixedIncomeUseCase>()) {
      Get.put(
        DeleteFixedIncomeUseCase(Get.find<FixedIncomeRepository>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 4. Controllers (المتحكمات) -> تم تفعيل الاستدعاء الكسول مع إمكانية إعادة الإحياء الفوري
    // ---------------------------------------------------------------------

    // متحكم قائمة المصروفات الرئيسي
    Get.lazyPut<FixedIncomeListController>(
      () => FixedIncomeListController(
        getFixedIncomesUseCase: Get.find<GetFixedIncomesUseCase>(),
      ),
      fenix: true,
    );

    // متحكم إضافة مصروف جديد
    Get.lazyPut<FixedIncomeController>(
      () => FixedIncomeController(
        getUseCase: Get.find<GetFixedIncomesUseCase>(),
        addUseCase: Get.find<AddFixedIncomeUseCase>(),
        updateUseCase: Get.find<UpdateFixedIncomeUseCase>(),
        deleteUseCase: Get.find<DeleteFixedIncomeUseCase>(),
      ),
      fenix: true,
    );
  }
}
