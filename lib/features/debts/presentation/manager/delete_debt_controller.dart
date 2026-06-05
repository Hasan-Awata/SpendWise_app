import 'package:get/get.dart';
import 'package:spendwise/features/debts/domain/entities/shared_debt_entity.dart';
import 'package:spendwise/features/debts/domain/usecases/delete_debt_usecase.dart';
import 'package:spendwise/features/debts/presentation/manager/debts_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class DeleteDebtController extends GetxController {
  DeleteDebtController({
    required this.deleteDebtUseCase,
    required this.debtsListController,
  });

  final DeleteDebtUseCase deleteDebtUseCase;

  final DebtsListController debtsListController;

  final RxBool isLoadingDelete = false.obs;

  Future<void> deleteDebt(SharedDebtEntity debt) async {
    if (isLoadingDelete.value) return;

    try {
      isLoadingDelete.value = true;

      final result = await deleteDebtUseCase.call(debt);

      result.fold(
        (failure) {
          _handleError("فشل الحذف", failure.message);
        },
        (_) {
          debtsListController.debts.removeWhere(
            (e) =>
                (e.localId == debt.localId) ||
                (e.debtId != null && e.debtId == debt.debtId),
          );

          debtsListController.debts.refresh();

          debtsListController.updateDashboardTotals();
        },
      );
    } catch (e) {
      _handleError("خطأ", e.toString());
    } finally {
      isLoadingDelete.value = false;
    }
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
