// ==========================
// UpdateIncomeController
// نسخة مطورة ومتوافقة مع الواجهات الجديدة
// ==========================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
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

  final titleController = TextEditingController();
  final amountController = TextEditingController();

  IncomeEntity? currentIncome;

  void setIncome(IncomeEntity income) {
    currentIncome = income;

    titleController.text = income.title;
    amountController.text = income.amount.toString();
  }

  Future<void> updateIncome() async {
    if (currentIncome == null) return;

    isLoadingUpdate.value = true;

    final updated = IncomeEntity(
      localId: currentIncome!.localId,
      userId: currentIncome!.userId,
      wallet: currentIncome!.wallet,
      walletId: currentIncome!.walletId,
      incomeTagId: currentIncome!.incomeTagId,
      tag: currentIncome!.tag,
      date: currentIncome!.date,
      description: currentIncome!.description,

      title: titleController.text.trim(),
      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
    );

    final result = await updateIncomeUseCase.call(updated);

    result.fold((failure) => _handleError("فشل التحديث", failure.message), (_) {
      final index = incomesListController.incomesList.indexWhere(
        (e) => e.localId == updated.localId,
      );

      if (index != -1) {
        incomesListController.incomesList[index] = updated;
        incomesListController.incomesList.refresh();
      }

      incomesListController.calculateTotals();

      Get.back();
      HelperFunction.showSnackBar("تم بنجاح", "تم تحديث الدخل");
    });

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
