// // تعليق: حذف دخل — جاهز لاستدعاء من قائمة الدخل لاحقاً
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/domain/usecases/delete_income_usecase.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';

class DeleteIncomeController extends GetxController {
  DeleteIncomeController({
    required this.deleteIncomeUseCase,
    required this.incomesListController,
  });

  final DeleteIncomeUseCase deleteIncomeUseCase;
  final IncomesListController incomesListController;

  final isLoadingDelete = false.obs;

  Future<void> deleteIncome(int incomeId) async {
    isLoadingDelete.value = true;
    final result = await deleteIncomeUseCase.call(incomeId);

    result.fold((failure) => _handleError("فشل الحذف", failure.message), (_) {
      incomesListController.incomesList.removeWhere((e) => e.id == incomeId);
      incomesListController.refreshMonthlyIncomeTotal();
      HelperFunction.showSnackBar("محذوف", "تم حذف السجل بنجاح");
    });
    isLoadingDelete.value = false;
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
