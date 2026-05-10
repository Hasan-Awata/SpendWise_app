// ==========================
// UpdateExpenseController
// نسخة مطورة ومتوافقة مع الواجهات الجديدة
// ==========================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/domain/usecases/update_expense_usecases.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class UpdateExpenseController extends GetxController {
  UpdateExpenseController({
    required this.updateExpenseUseCase,
    required this.expensesListController,
  });

  final UpdateExpenseUsecase updateExpenseUseCase;
  final ExpensesListController expensesListController;

  final isLoadingUpdate = false.obs;

  final titleController = TextEditingController();
  final amountController = TextEditingController();

  ExpenseEntity? currentExpense;

  void setExpense(ExpenseEntity expense) {
    currentExpense = expense;

    titleController.text = expense.title;
    amountController.text = expense.amount.toString();
  }

  Future<void> updateExpense() async {
    if (currentExpense == null) return;

    isLoadingUpdate.value = true;

    final updated = ExpenseEntity(
      localId: currentExpense!.localId,
      userId: currentExpense!.userId,
      wallet: currentExpense!.wallet,
      walletId: currentExpense!.walletId,
      expenseTagId: currentExpense!.expenseTagId,
      tag: currentExpense!.tag,
      date: currentExpense!.date,
      description: currentExpense!.description,

      title: titleController.text.trim(),
      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
    );

    final result = await updateExpenseUseCase.call(updated);

    result.fold((failure) => _handleError("فشل التحديث", failure.message), (_) {
      final index = expensesListController.expensesList.indexWhere(
        (e) => e.localId == updated.localId,
      );

      if (index != -1) {
        expensesListController.expensesList[index] = updated;
        expensesListController.expensesList.refresh();
      }

      expensesListController.calculateTotals();

      Get.back();
      HelperFunction.showSnackBar("تم بنجاح", "تم تحديث المصروف");
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
