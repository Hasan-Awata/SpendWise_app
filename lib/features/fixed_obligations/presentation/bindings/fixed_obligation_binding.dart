import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/fixed_obligations/data/datasources/fixed_obligation_local_datasource_impl.dart';
import 'package:spendwise/features/fixed_obligations/data/datasources/fixed_obligation_remote_datasource.dart';
import 'package:spendwise/features/fixed_obligations/data/repositories/fixed_obligation_repository.dart';
import 'package:spendwise/features/fixed_obligations/domain/repositories/fixed_obligation_repository_impl.dart';
import 'package:spendwise/features/fixed_obligations/domain/usecases/add_fixed_obligation_usecase.dart';
import 'package:spendwise/features/fixed_obligations/domain/usecases/delete_fixed_obligation_usecase.dart';
import 'package:spendwise/features/fixed_obligations/domain/usecases/get_fixed_obligation_usecase.dart';
import 'package:spendwise/features/fixed_obligations/domain/usecases/update_fixed_obligation_usecases.dart';
import 'package:spendwise/features/fixed_obligations/presentation/manager/fixed_obligation_controller.dart';
import 'package:spendwise/features/fixed_obligations/presentation/manager/fixed_obligation_list_controller.dart';

import '../../data/datasources/fixed_obligation_local_datasource.dart';
import '../../data/datasources/fixed_obligation_remote_datasource_impl.dart';

class FixedObligationBinding extends Bindings {
  @override
  void dependencies() {
    // ---------------------------------------------------------------------
    // 1. Data Sources (مصادر البيانات)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<FixedObligationRemoteDataSource>()) {
      Get.put<FixedObligationRemoteDataSource>(
        FixedObligationRemoteDataSourceImpl(
          network: Get.find<NetworkService>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<FixedObligationLocalDataSource>()) {
      Get.put<FixedObligationLocalDataSource>(
        FixedObligationLocalDataSourceImpl(Get.find<Isar>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 2. Repository (المستودع)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<FixedObligationRepository>()) {
      Get.put<FixedObligationRepository>(
        FixedObligationRepositoryImpl(
          remote: Get.find(),
          syncQueueRepository: Get.find(),
          localDataSource: Get.find(),
        ),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 3. Use Cases (حالات الاستخدام)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<AddFixedObligationUseCase>()) {
      Get.put(
        AddFixedObligationUseCase(Get.find<FixedObligationRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<GetFixedObligationsUseCase>()) {
      Get.put(
        GetFixedObligationsUseCase(Get.find<FixedObligationRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<UpdateFixedObligationUseCase>()) {
      Get.put(
        UpdateFixedObligationUseCase(Get.find<FixedObligationRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<DeleteFixedObligationUseCase>()) {
      Get.put(
        DeleteFixedObligationUseCase(Get.find<FixedObligationRepository>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 4. Controllers (المتحكمات) -> تم تفعيل الاستدعاء الكسول مع إمكانية إعادة الإحياء الفوري
    // ---------------------------------------------------------------------

    // متحكم قائمة المصروفات الرئيسي
    Get.lazyPut<FixedObligationListController>(
      () => FixedObligationListController(
        getFixedObligationsUseCase: Get.find<GetFixedObligationsUseCase>(),
      ),
      fenix: true,
    );

    // متحكم إضافة مصروف جديد
    Get.lazyPut<FixedObligationController>(
      () => FixedObligationController(
        getUseCase: Get.find<GetFixedObligationsUseCase>(),
        addUseCase: Get.find<AddFixedObligationUseCase>(),
        updateUseCase: Get.find<UpdateFixedObligationUseCase>(),
        deleteUseCase: Get.find<DeleteFixedObligationUseCase>(),
        walletsListController: Get.find(),
      ),
      fenix: true,
    );
  }
}
