import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/helper_function.dart';

class ExpenseController extends GetxController {
  var expenseAmount = 0.0.obs;
  var selectedValue = 'General'.obs;
  var selectedDate = DateTime.now().obs;

  final List<String> values = ['General', 'Food', 'Transport', 'Bills'].obs;

  Future<void> fetchDate(BuildContext context) async {
    DateTime? pickedDate = await HelperFunction.chooseDate(context);
    if (context.mounted) {
      if (pickedDate != null && pickedDate != selectedDate.value) {
        selectedDate.value = pickedDate;
      }
    }
  }

  void saveExpense() {
    if (expenseAmount.value <= 0) {
      Get.snackbar(
        'Invalid amount',
        'Enter an amount greater than zero',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SpColor.expenseRed.withValues(alpha: 0.9),
        colorText: SpColor.offWhite,
      );
      return;
    }

    debugPrint(
      'Expense: ${expenseAmount.value} in ${selectedValue.value} on ${selectedDate.value}',
    );

    Get.snackbar(
      'Saved',
      'Expense recorded',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SpColor.surfaceNavy,
      colorText: SpColor.offWhite,
    );
    Get.back();
  }
}
