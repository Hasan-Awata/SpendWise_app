// // UI: features/expense/presentation/pages/expense_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/presentation/manager/delete_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/update_expense_controller.dart';

class ExpenseListView extends GetView<ExpensesListController> {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // لون الخلفية الداكن
      appBar: AppBar(
        title: const Text(
          "Expenses",
          style: TextStyle(color: Color(0xFFF15A5A)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF15A5A),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Get.toNamed('/add-expense'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.expensesList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF15A5A)),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchExpenses(isRefresh: true),
          color: SpColor.expenseRed,
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
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(
          expense.category!.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          expense.date.toString().split(' ')[0],
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${expense.amount} SAR",
              style: const TextStyle(
                color: Color(0xFFF15A5A),
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
              onPressed: () {
                final updateController = Get.find<UpdateExpenseController>();
                showUpdateDialog(expense, updateController);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                // نقوم بجلب الـ Controller الخاص بالحذف واستدعاء الدالة
                final deleteController = Get.find<DeleteExpenseController>();
                showDeleteDialog(expense, deleteController);
              },
            ),
          ],
        ),
      ),
    );
  }

  // // UI: دالة إظهار حوار التعديل السريع
  void showUpdateDialog(
    ExpenseModel expense,
    UpdateExpenseController updateController,
  ) {
    // تهيئة الحقول بالبيانات الحالية للمصروف
    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );
    final categoryController = TextEditingController(
      text: expense.category!.name,
    );

    Get.defaultDialog(
      title: "Update Expense",
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
            label: "المبلغ (SAR)",
            isNumber: true,
          ),
          const SizedBox(height: 15),
          _buildDialogTextField(
            controller: categoryController,
            label: "Source/Category",
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
            onPressed: updateController.isLoading.value
                ? null
                : () {
                    // تحديث الكائن بالقيم الجديدة
                    expense.amount =
                        double.tryParse(amountController.text) ??
                        expense.amount;
                    expense.category!.name = categoryController.text;

                    updateController.updateExpense(expense);
                  },
            child: updateController.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
      ),
    );
  }

  // دالة مساعدة لبناء الحقول داخل الـ Dialog لتقليل تكرار الكود
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

  // // UI: Helper function for Deletion
  void showDeleteDialog(
    ExpenseModel expense,
    DeleteExpenseController deleteController,
  ) {
    Get.defaultDialog(
      title: "Confirm Delete",
      middleText: "Are you sure you want to delete this expense?",
      backgroundColor: const Color(0xFF1E293B),
      titleStyle: const TextStyle(color: Color(0xFFF15A5A)),
      middleTextStyle: const TextStyle(color: Colors.white),
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFF15A5A),
      onConfirm: () {
        deleteController.deleteExpense(expense);
        Get.back();
      },
    );
  }
}
