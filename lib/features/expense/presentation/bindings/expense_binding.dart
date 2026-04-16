// // Logic: features/expense/presentation/bindings/expense_binding.dart
import 'package:get/get.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource_impl.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/expense/domain/repositories/expense_repository_impl.dart';
import 'package:spendwise/features/expense/domain/usecases/delete_expense_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/get_all_expenses_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/sync_expense_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/update_expense_usecases.dart';
import 'package:spendwise/features/expense/presentation/manager/add_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/delete_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/update_expense_controller.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/datasources/expense_remote_datasource_impl.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';

// This binding class ensures all expense-related dependencies are instantiated immediately using Get.put
class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Sources (مصادر البيانات)
    // Instant injection of Remote DataSource
    Get.put<ExpenseRemoteDataSource>(
      ExpenseRemoteDataSourceImpl(dio: Get.find()),
    );

    // Instant injection of Local DataSource for Hive
    Get.put<ExpenseLocalDataSource>(ExpenseLocalDataSourceImpl());

    // 2. Repository (المستودع)
    // Linking remote and local data management immediately
    Get.put<ExpenseRepository>(
      ExpenseRepositoryImpl(
        remoteDatasource: Get.find(),
        localDataSource: Get.find(),
      ),
    );

    // 3. Use Cases (حالات الاستخدام)
    // Instantiating all use cases as separate objects for clean architecture compliance
    Get.put(AddExpenseUsecase(Get.find()));
    Get.put(UpdateExpenseUsecase(Get.find()));
    Get.put(DeleteExpenseUsecase(Get.find()));
    Get.put(GetExpensesUsecase(Get.find()));
    Get.put(GetAllLocalExpensesUsecase(Get.find()));
    Get.put(SyncPendingExpensesUsecase(Get.find()));

    // 4. Controllers (المتحكمات)

    // Controller for listing, pagination, and monthly statistics
    Get.put(
      ExpensesListController(
        getExpensesUseCase: Get.find(),
        getAllLocalExpensesUsecase: Get.find(),
        syncExpenseUsecase: Get.find(),
      ),
    );

    // Controller for the add expense process
    Get.put(
      AddExpenseController(
        addUseCase: Get.find(),
        walletsListController: Get.find(),
        tagController: Get.find(),
        tagActionController: Get.find(),
        expensesListController: Get.find(),
      ),
    );

    // Controller for updating existing expense data
    Get.put(UpdateExpenseController(updateUseCase: Get.find()));

    // Controller for expense deletion
    Get.put(DeleteExpenseController(deleteUseCase: Get.find()));
  }
}
