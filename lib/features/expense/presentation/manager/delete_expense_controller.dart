// delete_expense_controller.dart

import 'package:get/get.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/domain/usecases/delete_expense_usecase.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class DeleteExpenseController extends GetxController {
  DeleteExpenseController({
    required this.deleteUseCase,
    required this.expensesListController,
  });

  final DeleteExpenseUsecase deleteUseCase;

  final ExpensesListController expensesListController;

  // =========================
  // STATE
  // =========================

  final isLoadingDelete = false.obs;

  // =========================
  // DELETE
  // =========================

  Future<void> deleteExpense(ExpenseEntity expense) async {
    try {
      isLoadingDelete.value = true;

      // =====================
      // OPTIMISTIC DELETE
      // =====================

      expensesListController.deleteExpenseLocally(expense.localId);

      // =====================
      // DELETE FROM DATABASE/API
      // =====================

      final result = await deleteUseCase.call(expense);

      result.fold(
        (failure) {
          _handleError("فشل الحذف", failure.message);
        },
        (_) {
          expensesListController.updateDashboardTotals();

          Get.back();
          // HelperFunction.showSnackBar("تم الحذف", "تم حذف المصروف بنجاح");
        },
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoadingDelete.value = false;
    }
  }

  // =========================
  // ERROR
  // =========================

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
