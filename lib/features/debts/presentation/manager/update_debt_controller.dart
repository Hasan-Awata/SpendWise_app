import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/debts/domain/entities/shared_debt_entity.dart';
import 'package:spendwise/features/debts/domain/usecases/update_debt_usecase.dart';
import 'package:spendwise/features/debts/presentation/manager/debts_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class UpdateDebtController extends GetxController {
  UpdateDebtController({
    required this.updateDebtUseCase,
    required this.debtsListController,
  });

  final UpdateDebtUseCase updateDebtUseCase;

  final DebtsListController debtsListController;

  final isLoadingUpdate = false.obs;

  final titleController = TextEditingController();

  final amountController = TextEditingController();

  SharedDebtEntity? currentDebt;

  void setDebt(SharedDebtEntity debt) {
    currentDebt = debt;

    titleController.text = debt.title;

    amountController.text = debt.amount.toString();
  }

  Future<void> updateDebt() async {
    if (currentDebt == null) return;

    isLoadingUpdate.value = true;

    final updated = SharedDebtEntity(
      localId: currentDebt!.localId,

      debtId: currentDebt!.debtId,

      creditorId: currentDebt!.creditorId,

      debtorId: currentDebt!.debtorId,

      creditorWalletId: currentDebt!.creditorWalletId,

      debtorWalletId: currentDebt!.debtorWalletId,

      status: currentDebt!.status,

      dueDate: currentDebt!.dueDate,

      createdAt: currentDebt!.createdAt,

      paidAmount: currentDebt!.paidAmount,

      title: titleController.text.trim(),

      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
    );

    final result = await updateDebtUseCase.call(updated);

    result.fold(
      (failure) {
        _handleError("فشل التحديث", failure.message);
      },
      (_) {
        final index = debtsListController.debts.indexWhere(
          (e) => e.localId == updated.localId,
        );

        if (index != -1) {
          debtsListController.debts[index] = updated;

          debtsListController.debts.refresh();
        }

        debtsListController.updateDashboardTotals();

        Get.back();

        HelperFunction.showSnackBar("تم بنجاح", "تم تحديث الدين");
      },
    );

    isLoadingUpdate.value = false;
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  @override
  void onClose() {
    titleController.dispose();

    amountController.dispose();

    super.onClose();
  }
}
