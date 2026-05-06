// // UI: features/expense/presentation/pages/expense_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/presentation/manager/delete_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/update_expense_controller.dart';

// // عرض قائمة المصروفات باستخدام GetView للتحكم في الحالة
class ExpenseListView extends GetView<ExpensesListController> {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // لون الخلفية الداكن
      appBar: AppBar(
        title: const Text(
          "المصروفات",
          style: TextStyle(color: Color(0xFFF15A5A)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF15A5A),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Get.toNamed('/add-expense'),
      ),
      body: Obx(() {
        // // التحقق من حالة التحميل وإذا كانت القائمة فارغة
        if (controller.isLoading.value && controller.expensesList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF15A5A)),
          );
        }

        return RefreshIndicator(
          color: SpColor.accentBlue,
          backgroundColor: SpColor.surfaceNavy,
          onRefresh: () => controller.fetchExpenses(isRefresh: true),

          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: controller.scrollController,
            itemCount:
                controller.expensesList.length +
                (controller.hasMoreData.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < controller.expensesList.length) {
                final expense = controller.expensesList[index];
                return _buildExpenseItem(expense);
              } else {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildExpenseItem(ExpenseModel expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SpColor.expenseRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: SpColor.expenseRed,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd').format(expense.date),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (expense.wallet == null)
                    ? "+${expense.amount.toStringAsFixed(2)}"
                    : "${expense.wallet?.currency.code} +${expense.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: SpColor.expenseRed,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // زر التعديل
                  IconButton(
                    icon: const Icon(
                      Icons.edit_note,
                      color: Colors.blueGrey,
                      size: 22,
                    ),
                    onPressed: () {
                      final updateController =
                          Get.find<UpdateExpenseController>();
                      showUpdateDialog(expense, updateController);
                    },
                  ),
                  // زر الحذف
                  IconButton(
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () {
                      final deleteController =
                          Get.find<DeleteExpenseController>();
                      showDeleteDialog(expense, deleteController);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // // UI: دالة إظهار حوار التعديل السريع باللغة العربية
  void showUpdateDialog(
    ExpenseModel expense,
    UpdateExpenseController updateController,
  ) {
    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );
    final categoryController = TextEditingController(
      text: expense.category!.name,
    );

    Get.defaultDialog(
      title: "تحديث المصروف",
      backgroundColor: const Color(0xFF1E293B),
      titleStyle: const TextStyle(
        color: Color(0xFFF15A5A),
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          _buildDialogTextField(
            controller: amountController,
            label: "المبلغ (ر.س)",
            isNumber: true,
          ),
          const SizedBox(height: 15),
          _buildDialogTextField(
            controller: categoryController,
            label: "الفئة / المصدر",
          ),
        ],
      ),
      confirm: Obx(
        () => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF15A5A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: updateController.isLoadingUpdate.value
                ? null
                : () {
                    expense.amount =
                        double.tryParse(amountController.text) ??
                        expense.amount;
                    expense.category!.name = categoryController.text;

                    updateController.updateExpense(expense);
                  },
            child: updateController.isLoadingUpdate.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("تحديث", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("إلغاء", style: TextStyle(color: Colors.white54)),
      ),
    );
  }

  // // دالة مساعدة لبناء حقول النص داخل الحوار
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFF15A5A), fontSize: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFF15A5A)),
        ),
      ),
    );
  }

  // // UI: دالة إظهار حوار تأكيد الحذف
  void showDeleteDialog(
    ExpenseModel expense,
    DeleteExpenseController deleteController,
  ) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد أنك تريد حذف هذا المصروف؟",
      backgroundColor: const Color(0xFF1E293B),
      titleStyle: const TextStyle(color: Color(0xFFF15A5A)),
      middleTextStyle: const TextStyle(color: Colors.white),
      textConfirm: "حذف",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFF15A5A),
      onConfirm: () {
        deleteController.deleteExpense(expense);
        Get.back();
      },
    );
  }
}
