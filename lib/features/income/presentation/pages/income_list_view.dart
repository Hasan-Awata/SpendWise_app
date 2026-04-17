// // UI: عرض قائمة الدخل مع خيارات التعديل والحذف السريع
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/presentation/manager/delete_income_controller.dart';
import 'package:spendwise/features/income/presentation/manager/update_income_controller.dart';
import '../manager/incomes_list_controller.dart';
// تأكد من استيراد المتحكمات الجديدة هنا
// import '../manager/update_income_controller.dart';
// import '../manager/delete_income_controller.dart';

class IncomeListView extends GetView<IncomesListController> {
  const IncomeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: AppBar(
        title: const Text(
          "Income History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        foregroundColor: SpColor.incomeGreen,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SpColor.incomeGreen,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Get.toNamed('/add-income'),
      ),
      body: RefreshIndicator(
        color: SpColor.incomeGreen,
        onRefresh: () async => controller.fetchAllIncomes(isRefresh: true),
        child: Obx(() {
          if (controller.isLoading.value && controller.incomesList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: SpColor.incomeGreen),
            );
          }

          if (controller.incomesList.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: controller.incomesList.length,
            itemBuilder: (context, index) {
              return _buildIncomeCard(controller.incomesList[index]);
            },
          );
        }),
      ),
    );
  }

  Widget _buildIncomeCard(IncomeModel income) {
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
              color: SpColor.incomeGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: SpColor.incomeGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd').format(income.date),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+${income.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: SpColor.incomeGreen,
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
                    onPressed: () => _showUpdateIncomeDialog(income),
                  ),
                  // زر الحذف
                  IconButton(
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () => _showDeleteIncomeDialog(income),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Dialogs المضافة ---
  void _showDeleteIncomeDialog(IncomeModel income) {
    Get.defaultDialog(
      title: "Delete Income",
      middleText: "Are you sure you want to remove this record?",
      backgroundColor: SpColor.primaryDark2,
      titleStyle: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
      ),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        // افترضنا وجود DeleteIncomeController محقون في Binding
        Get.find<DeleteIncomeController>().deleteIncome(income);
        Get.back();
      },
    );
  }

  void _showUpdateIncomeDialog(IncomeModel income) {
    final titleController = TextEditingController(text: income.title);
    final amountController = TextEditingController(
      text: income.amount.toString(),
    );

    Get.defaultDialog(
      title: "Update Income",
      backgroundColor: SpColor.primaryDark2,
      titleStyle: const TextStyle(
        color: SpColor.incomeGreen,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          _buildDialogField(controller: titleController, label: "Title/Source"),
          const SizedBox(height: 15),
          _buildDialogField(
            controller: amountController,
            label: "Amount",
            isNumber: true,
          ),
        ],
      ),
      confirm: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: SpColor.incomeGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            income.title = titleController.text;
            income.amount =
                double.tryParse(amountController.text) ?? income.amount;
            print("incomeID===> ${income.remoteId}");
            Get.find<UpdateIncomeController>().updateIncome(income);
            Get.back();
          },
          child: const Text("Update", style: TextStyle(color: Colors.white)),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
      ),
    );
  }

  Widget _buildDialogField({
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
        labelStyle: const TextStyle(color: SpColor.incomeGreen, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: SpColor.incomeGreen),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No income records found",
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
