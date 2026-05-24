import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:spendwise/core/services/init_isar.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_local_datasource.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_local_datasource_impl.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_remote_datasource.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_remote_datasource_impl.dart';
import 'package:spendwise/features/budget/data/repositrory/category_budget_repository.dart';
import 'package:spendwise/features/budget/data/repositrory/category_budget_repository_impl.dart';
import 'package:spendwise/features/budget/domain/usecases/add_category_budget_usecase.dart';
import 'package:spendwise/features/budget/domain/usecases/delete_category_budget_usecase.dart';
import 'package:spendwise/features/budget/domain/usecases/get_category_budget_usecase.dart';
import 'package:spendwise/features/budget/domain/usecases/update_category_budget_usecase.dart';
import 'package:spendwise/features/budget/presentation/manager/add_category_budget_controller.dart';
import 'package:spendwise/features/budget/presentation/manager/category_budget_list_controller.dart';
import 'package:spendwise/features/budget/presentation/manager/update_category_budget_controller.dart';

class CategoryBudgetBinding extends Bindings {
  @override
  void dependencies() {
    // =========================================================
    // Repository
    // =========================================================

    Get.lazyPut<CategoryBudgetRemoteDatasource>(
      () => CategoryBudgetRemoteDatasourceImpl(client: http.Client()),
      fenix: true,
    );
    Get.lazyPut<CategoryBudgetLocalDatasource>(
      () => CategoryBudgetLocalDatasourceImpl(InitIsar.isar!),

      fenix: true,
    );

    Get.lazyPut<CategoryBudgetRepository>(
      () => CategoryBudgetRepositoryImpl(
        remote: Get.find(),
        local: Get.find(),
        syncQueueRepository: Get.find(),
      ),
    );

    // =========================================================
    // UseCases
    // =========================================================
    Get.lazyPut(() => AddCategoryBudgetUseCase(Get.find()));
    Get.lazyPut(() => UpdateCategoryBudgetUsecase(Get.find()));
    Get.lazyPut(() => DeleteCategoryBudgetUseCase(Get.find()));
    Get.lazyPut(() => GetAllCategoryBudgetsUseCase(Get.find()));

    // =========================================================
    // Controllers
    // =========================================================

    // LIST
    Get.put(
      CategoryBudgetListController(getBudgetsUseCase: Get.find()),
      permanent: true,
    );

    // ADD
    Get.lazyPut(
      () => ManageCategoryBudgetController(updateBudgetUseCase: Get.find()),
    );

    // UPDATE
    Get.lazyPut(
      () => UpdateCategoryBudgetController(updateBudgetUseCase: Get.find()),
    );
  }
}
