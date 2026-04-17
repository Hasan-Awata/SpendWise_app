// // تعليق: متحكم تحديث بيانات مصروف — يدعم تحديث الحالة الفوري (Reactive UI)
import 'package:get/get.dart';
import 'package:spendwise/features/expense/domain/usecases/update_expense_usecases.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';

class UpdateExpenseController extends GetxController {
  UpdateExpenseController({
    required this.updateUseCase,
    required this.expensesListController,
  });

  final UpdateExpenseUsecase updateUseCase;
  final ExpensesListController expensesListController;

  final RxBool isLoadingUpdate = false.obs;

  Future<void> updateExpense(ExpenseModel updatedExpense) async {
    isLoadingUpdate.value = true;

    final result = await updateUseCase.call(updatedExpense);

    result.fold((failure) => _handleError("فشل التحديث", failure.message), (_) {
      // البحث عن العنصر المعدل في القائمة الحالية وتحديثه فوراً
      final index = expensesListController.expensesList.indexWhere(
        (e) => e.localId == updatedExpense.localId,
      );

      if (index != -1) {
        expensesListController.expensesList[index] = updatedExpense;
        expensesListController.expensesList.refresh(); // إخطار الواجهة بالتغيير
      }

      // إعادة حساب الإجماليات (مثل إجمالي المصاريف الشهرية)
      expensesListController.calculateTotals();

      HelperFunction.showSnackBar("تم بنجاح", "تم تحديث بيانات المصروف");

      // إغلاق أي نافذة مفتوحة (مثل BottomSheet أو Dialog)
      if (Get.isOverlaysOpen) Get.back();
    });

    isLoadingUpdate.value = false;
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
