// // تعليق: تعديل دخل — جاهز لشاشة التعديل لاحقاً
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/domain/usecases/update_income_usecase.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';

class UpdateIncomeController extends GetxController {
  UpdateIncomeController({
    required this.updateIncomeUseCase,
    required this.incomesListController,
  });

  final UpdateIncomeUseCase updateIncomeUseCase;
  final IncomesListController incomesListController;

  final isLoadingUpdate = false.obs;

  Future<void> updateIncome(int incomeId, IncomeModel updatedData) async {
    isLoadingUpdate.value = true;
    final result = await updateIncomeUseCase.call(incomeId, updatedData);

    result.fold((failure) => _handleError("فشل التحديث", failure.message), (_) {
      final index = incomesListController.incomesList.indexWhere(
        (e) => e.id == incomeId,
      );
      if (index != -1) {
        incomesListController.incomesList[index] = updatedData;
      }
      incomesListController.refreshMonthlyIncomeTotal();
      HelperFunction.showSnackBar("تم بنجاح", "تم تحديث البيانات");
    });
    isLoadingUpdate.value = false;
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
