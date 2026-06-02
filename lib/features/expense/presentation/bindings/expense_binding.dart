import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource_impl.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/expense/domain/repositories/expense_repository_impl.dart';
import 'package:spendwise/features/expense/domain/usecases/delete_expense_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/update_expense_usecases.dart';
import 'package:spendwise/features/expense/presentation/manager/add_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/delete_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/update_expense_controller.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';

import '../../data/datasources/expense_local_datasource.dart';
import '../../data/datasources/expense_remote_datasource_impl.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    // ---------------------------------------------------------------------
    // 1. Data Sources (مصادر البيانات)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<ExpenseRemoteDataSource>()) {
      Get.put<ExpenseRemoteDataSource>(
        ExpenseRemoteDataSourceImpl(network: Get.find<NetworkService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ExpenseLocalDataSource>()) {
      Get.put<ExpenseLocalDataSource>(
        ExpenseLocalDataSourceImpl(Get.find<Isar>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 2. Repository (المستودع)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.put<ExpenseRepository>(
        ExpenseRepositoryImpl(
          localDataSource: Get.find<ExpenseLocalDataSource>(),
          syncQueueRepository: Get.find<SyncQueueRepository>(),
          remote: Get.find<ExpenseRemoteDataSource>(),
        ),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 3. Use Cases (حالات الاستخدام)
    // ---------------------------------------------------------------------
    if (!Get.isRegistered<AddExpenseUsecase>()) {
      Get.put(
        AddExpenseUsecase(Get.find<ExpenseRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<GetExpensesUsecase>()) {
      Get.put(
        GetExpensesUsecase(Get.find<ExpenseRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<UpdateExpenseUsecase>()) {
      Get.put(
        UpdateExpenseUsecase(Get.find<ExpenseRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<DeleteExpenseUsecase>()) {
      Get.put(
        DeleteExpenseUsecase(Get.find<ExpenseRepository>()),
        permanent: true,
      );
    }

    // ---------------------------------------------------------------------
    // 4. Controllers (المتحكمات) -> تم تفعيل الاستدعاء الكسول مع إمكانية إعادة الإحياء الفوري
    // ---------------------------------------------------------------------

    // متحكم قائمة المصروفات الرئيسي
    Get.lazyPut<ExpensesListController>(
      () => ExpensesListController(
        getExpensesUseCase: Get.find<GetExpensesUsecase>(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
      ),
      fenix: true,
    );

    // متحكم إضافة مصروف جديد
    Get.lazyPut<AddExpenseController>(
      () => AddExpenseController(
        addUseCase: Get.find<AddExpenseUsecase>(),
        walletsListController: Get.find(),
        tagController: Get.find(),
        tagActionController: Get.find(),
        expensesListController: Get.find<ExpensesListController>(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
      ),
      fenix: true,
    );

    // متحكم تعديل المصروفات
    Get.lazyPut<UpdateExpenseController>(
      () => UpdateExpenseController(
        updateExpenseUseCase: Get.find<UpdateExpenseUsecase>(),
        expensesListController: Get.find<ExpensesListController>(),
      ),
      fenix: true,
    );

    // متحكم حذف المصروفات
    Get.lazyPut<DeleteExpenseController>(
      () => DeleteExpenseController(
        deleteUseCase: Get.find<DeleteExpenseUsecase>(),
        expensesListController: Get.find<ExpensesListController>(),
      ),
      fenix: true,
    );
  }
}
