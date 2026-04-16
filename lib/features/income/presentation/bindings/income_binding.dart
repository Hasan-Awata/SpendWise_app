// // تعليق: ملف IncomeBinding المعدل لضمان حقن كافة التبعيات فورياً باستخدام Get.put لتجنب أي تأخير أو أخطاء "Not Found"
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource_impl.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/data/repositories/income_repository_impl.dart';
import 'package:spendwise/features/income/domain/usecases/add_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/delete_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/get_all_local_incomes_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/get_incomes_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/synced_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/update_income_usecase.dart';
import 'package:spendwise/features/income/presentation/manager/add_income_controller.dart';
import 'package:spendwise/features/income/presentation/manager/delete_income_controller.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/income/presentation/manager/update_income_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/add_tag_controller.dart';

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Sources (مصادر البيانات)
    if (!Get.isRegistered<IncomeRemoteDatasource>()) {
      Get.put<IncomeRemoteDatasource>(
        IncomeRemoteDatasourceImpl(dio: Get.find<Dio>()),
      );
    }
    if (!Get.isRegistered<IncomeLocalDataSource>()) {
      Get.put<IncomeLocalDataSource>(IncomeLocalDataSourceImpl());
    }

    // 2. Repository (المستودع)
    if (!Get.isRegistered<IncomeRepository>()) {
      Get.put<IncomeRepository>(
        IncomeRepositoryImpl(
          localDataSource: Get.find<IncomeLocalDataSource>(),
          remoteDatasource: Get.find<IncomeRemoteDatasource>(),
        ),
      );
    }

    // 3. UseCases (حالات الاستخدام)
    if (!Get.isRegistered<AddIncomeUsecase>()) {
      Get.put(AddIncomeUsecase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<GetIncomesUsecase>()) {
      Get.put(GetIncomesUsecase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<GetAllLocalIncomesUsecase>()) {
      Get.put(GetAllLocalIncomesUsecase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<UpdateIncomeUseCase>()) {
      Get.put(UpdateIncomeUseCase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<DeleteIncomeUseCase>()) {
      Get.put(DeleteIncomeUseCase(Get.find<IncomeRepository>()));
    }
    if (!Get.isRegistered<SyncPendingIncomesUsecase>()) {
      Get.put(SyncPendingIncomesUsecase(Get.find()));
    }

    // 4. Controllers (المتحكمات)
    // تم تحويلها إلى Get.put لضمان عملها فور الدخول إلى واجهة الدخل
    if (!Get.isRegistered<IncomesListController>()) {
      Get.put(
        IncomesListController(
          getIncomesUseCase: Get.find<GetIncomesUsecase>(),
          getAllLocalIncomesUsecase: Get.find<GetAllLocalIncomesUsecase>(),
          syncIncomesUsecase: Get.find(),
        ),
      );
    }

    if (!Get.isRegistered<AddIncomeController>()) {
      Get.put(
        AddIncomeController(
          addIncomeUseCase: Get.find<AddIncomeUsecase>(),
          walletsListController: Get.find(),
          tagController: Get.find(),
          incomesListController: Get.find<IncomesListController>(),
          tagActionController: Get.find<TagActionController>(),
        ),
      );
    }

    if (!Get.isRegistered<UpdateIncomeController>()) {
      Get.put(
        UpdateIncomeController(
          updateIncomeUseCase: Get.find<UpdateIncomeUseCase>(),
          incomesListController: Get.find<IncomesListController>(),
        ),
      );
    }

    if (!Get.isRegistered<DeleteIncomeController>()) {
      Get.put(
        DeleteIncomeController(
          deleteIncomeUseCase: Get.find<DeleteIncomeUseCase>(),
          incomesListController: Get.find<IncomesListController>(),
        ),
      );
    }
  }
}
