// // تعليق: متحكم حذف مصروف
import 'package:get/get.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/expense/domain/usecases/delete_expense_usecase.dart';

class DeleteExpenseController extends GetxController {
  final DeleteExpenseUsecase deleteUseCase;

  DeleteExpenseController({required this.deleteUseCase});

  final RxBool isLoading = false.obs;

  Future<void> deleteExpense(ExpenseModel expense) async {
    isLoading.value = true;
    final result = await deleteUseCase.call(expense);
    Get.find<ExpensesListController>().fetchExpenses(isRefresh: true);
    result.fold(
      (failure) => HelperFunction.showSnackBar(
        "فشل الحذف",
        failure.message,
        isError: true,
      ),
      (_) => HelperFunction.showSnackBar("نجاح", "تم حذف المصروف بنجاح"),
    );
    isLoading.value = false;
  }
}
