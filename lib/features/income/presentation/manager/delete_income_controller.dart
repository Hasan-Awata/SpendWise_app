import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/income/domain/usecases/delete_income_usecase.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';

class DeleteIncomeController extends GetxController {
  DeleteIncomeController({
    required this.deleteIncomeUseCase,
    required this.incomesListController,
  });

  final DeleteIncomeUseCase deleteIncomeUseCase;
  final IncomesListController incomesListController;

  // ==========================
  // States
  // ==========================

  final RxBool isLoadingDelete = false.obs;

  // ==========================
  // Delete Income
  // ==========================

  Future<void> deleteIncome(IncomeEntity income) async {
    if (isLoadingDelete.value) return;

    try {
      isLoadingDelete.value = true;

      final result = await deleteIncomeUseCase.call(income);

      result.fold(
        (failure) {
          _handleError("فشل الحذف", failure.message);
        },
        (_) {
          // حذف ذكي من الواجهة مباشرة بدون reload

          incomesListController.incomesList.removeWhere(
            (e) =>
                e.localId == income.localId ||
                (e.id != null && e.id == income.id),
          );

          incomesListController.incomesList.refresh();

          // تحديث الإحصائيات

          incomesListController.calculateTotals();

          Get.back();
          HelperFunction.showSnackBar("تم الحذف", "تم حذف سجل الدخل بنجاح");
        },
      );
    } catch (e) {
      _handleError("خطأ", e.toString());
    } finally {
      isLoadingDelete.value = false;
    }
  }

  // ==========================
  // Error Handler
  // ==========================

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
