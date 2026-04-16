// // تعليق: متحكم تحديث بيانات مصروف
import 'package:get/get.dart';
import 'package:spendwise/features/expense/domain/usecases/update_expense_usecases.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';

class UpdateExpenseController extends GetxController {
  final UpdateExpenseUsecase updateUseCase;

  UpdateExpenseController({required this.updateUseCase});

  final RxBool isLoading = false.obs;

  Future<void> updateExpense(ExpenseModel expense) async {
    isLoading.value = true;
    final result = await updateUseCase.call(expense);

    result.fold(
      (failure) => HelperFunction.showSnackBar(
        "فشل التحديث",
        failure.message,
        isError: true,
      ),
      (_) {
        HelperFunction.showSnackBar("نجاح", "تم تحديث البيانات");
        Get.back();
      },
    );
    isLoading.value = false;
  }
}
