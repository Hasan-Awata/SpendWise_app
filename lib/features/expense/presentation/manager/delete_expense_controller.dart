// // تعليق: متحكم حذف مصروف — يدعم الحذف الذكي من الواجهة دون إعادة تحميل البيانات
import 'package:get/get.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/expense/domain/usecases/delete_expense_usecase.dart';

class DeleteExpenseController extends GetxController {
  DeleteExpenseController({
    required this.deleteUseCase,
    required this.expensesListController,
  });

  final DeleteExpenseUsecase deleteUseCase;
  final ExpensesListController expensesListController;

  final RxBool isLoadingDelete = false.obs;

  Future<void> deleteExpense(ExpenseModel expenseToDelete) async {
    isLoadingDelete.value = true;

    final result = await deleteUseCase.call(expenseToDelete);

    result.fold((failure) => _handleError("فشل الحذف", failure.message), (_) {
      // حذف العنصر من القائمة المحلية فوراً لتحسين استجابة التطبيق
      expensesListController.expensesList.removeWhere(
        (e) => e.localId == expenseToDelete.localId,
      );

      // إعادة حساب الإجماليات لتحديث أرقام المصروفات في الواجهة
      expensesListController.calculateTotals();

      HelperFunction.showSnackBar("تم بنجاح", "تم حذف المصروف بنجاح");

      // إغلاق أي نافذة تأكيد مفتوحة
      if (Get.isOverlaysOpen) Get.back();
    });

    isLoadingDelete.value = false;
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
