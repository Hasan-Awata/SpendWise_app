// Logic: features/expense/presentation/bindings/expense_binding.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource_impl.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/expense/domain/repositories/expense_repository_impl.dart';
import 'package:spendwise/features/expense/domain/usecases/delete_expense_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/get_all_expenses_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/update_expense_usecases.dart';
import 'package:spendwise/features/expense/presentation/manager/add_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/delete_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/update_expense_controller.dart';

import '../../data/datasources/expense_local_datasource.dart';
import '../../data/datasources/expense_remote_datasource_impl.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Sources (مصادر البيانات)
    // التحقق من التسجيل لمنع التكرار كما في كلاس الدخل
    if (!Get.isRegistered<ExpenseRemoteDataSource>()) {
      Get.put<ExpenseRemoteDataSource>(
        ExpenseRemoteDataSourceImpl(client: http.Client()),
      );
    }
    if (!Get.isRegistered<ExpenseLocalDataSource>()) {
      Get.put<ExpenseLocalDataSource>(
        ExpenseLocalDataSourceImpl(Get.find<Isar>()),
      );
    }

    // 2. Repository (المستودع)
    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.put<ExpenseRepository>(
        ExpenseRepositoryImpl(
          remoteDatasource: Get.find<ExpenseRemoteDataSource>(),
          localDataSource: Get.find<ExpenseLocalDataSource>(),
          network: Get.find<NetworkService>(),
        ),
      );
    }

    // 3. Use Cases (حالات الاستخدام)
    if (!Get.isRegistered<AddExpenseUsecase>()) {
      Get.put(AddExpenseUsecase(Get.find<ExpenseRepository>()));
    }
    if (!Get.isRegistered<GetExpensesUsecase>()) {
      Get.put(GetExpensesUsecase(Get.find<ExpenseRepository>()));
    }
    if (!Get.isRegistered<GetAllLocalExpensesUsecase>()) {
      Get.put(GetAllLocalExpensesUsecase(Get.find<ExpenseRepository>()));
    }
    if (!Get.isRegistered<UpdateExpenseUsecase>()) {
      Get.put(UpdateExpenseUsecase(Get.find<ExpenseRepository>()));
    }
    if (!Get.isRegistered<DeleteExpenseUsecase>()) {
      Get.put(DeleteExpenseUsecase(Get.find<ExpenseRepository>()));
    }

    // 4. Controllers (المتحكمات)
    // استخدام Get.put لضمان الجاهزية الفورية عند الانتقال لواجهة المصروفات
    if (!Get.isRegistered<ExpensesListController>()) {
      Get.put(
        ExpensesListController(
          getExpensesUseCase: Get.find<GetExpensesUsecase>(),
          getAllLocalExpensesUsecase: Get.find<GetAllLocalExpensesUsecase>(),

          userIdUsecase: Get.find<GetUserIdUsecase>(),
        ),
      );
    }

    if (!Get.isRegistered<AddExpenseController>()) {
      Get.put(
        AddExpenseController(
          addUseCase: Get.find<AddExpenseUsecase>(),
          walletsListController: Get.find(),
          tagController: Get.find(),
          tagActionController: Get.find(),
          expensesListController: Get.find<ExpensesListController>(),
          userIdUsecase: Get.find<GetUserIdUsecase>(),
        ),
      );
    }

    if (!Get.isRegistered<UpdateExpenseController>()) {
      Get.put(
        UpdateExpenseController(
          updateExpenseUseCase: Get.find<UpdateExpenseUsecase>(),
          expensesListController: Get.find<ExpensesListController>(),
        ),
      );
    }

    if (!Get.isRegistered<DeleteExpenseController>()) {
      Get.put(
        DeleteExpenseController(
          deleteUseCase: Get.find<DeleteExpenseUsecase>(),
          expensesListController: Get.find<ExpensesListController>(),
        ),
      );
    }
  }
}
