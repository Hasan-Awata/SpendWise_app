// lib/features/expense/presentation/pages/expense_list_view.dart
// ExpenseListView: Secure UI presentation frame listening to clean architectural expense streams with consistent semantic terms

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/presentation/manager/delete_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/update_expense_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    /* تم استبدال GetView بـ Get.put الضامن لإيقاظ وحقن الكنترولر 
       واستدعاء دالة جلب البيانات الخاصة به فور فتح الصفحة.
    */
    final controller = Get.put(Get.find<ExpensesListController>());

    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        foregroundColor: SpColor.expenseRed,
        title: const Text(
          "المصاريف", // تم تصحيح النصوص والخلط اللغوي
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SpColor.expenseRed,
        onPressed: () => Get.toNamed('/add-expense'),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "إضافة مصروف",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Obx(() {
        // التحقق الآمن في حال تحميل البيانات الأولى
        if (controller.isLoading.value && controller.expensesList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: SpColor.expenseRed),
          );
        }

        // معالجة القائمة الفارغة مع توفير زر إعادة محاولة مرن وهيكلي
        if (controller.expensesList.isEmpty) {
          return Center(
            child: ListView(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const Center(
                  child: Text(
                    "لا توجد مصاريف حالياً",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => controller.refreshExpenses(),
                    child: const Text(
                      "إعادة المحاولة",
                      style: TextStyle(color: SpColor.expenseRed),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: SpColor.expenseRed,
          onRefresh: controller.refreshExpenses,
          child: ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount:
                controller.expensesList.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.expensesList.length) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SpColor.expenseRed,
                    ),
                  ),
                );
              }

              final expense = controller.expensesList[index];
              return _buildExpenseItem(expense, controller);
            },
          ),
        );
      }),
    );
  }

  // =========================
  // ITEM
  // =========================

  Widget _buildExpenseItem(
    ExpenseEntity expense,
    ExpensesListController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(child: _buildDetails(expense)),
          const SizedBox(width: 12),
          _buildActions(expense, controller),
        ],
      ),
    );
  }

  // =========================
  // ICON
  // =========================

  Widget _buildIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [SpColor.expenseRed, SpColor.expenseRed.withOpacity(0.7)],
        ),
      ),
      child: const Icon(
        Icons.account_balance_wallet_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // =========================
  // DETAILS
  // =========================

  Widget _buildDetails(ExpenseEntity expense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          expense.title.trim().isEmpty ? 'بدون عنوان' : expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat('yyyy-MM-dd').format(expense.date),
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _syncStatus(expense.isSynced),
      ],
    );
  }

  // =========================
  // SYNC STATUS
  // =========================

  Widget _syncStatus(RxBool synced) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: synced.value
              ? Colors.green.withOpacity(0.12)
              : Colors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          synced.value ? 'متزامن' : 'غير متزامن',
          style: TextStyle(
            color: synced.value ? Colors.greenAccent : Colors.orangeAccent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // =========================
  // ACTIONS
  // =========================

  Widget _buildActions(
    ExpenseEntity expense,
    ExpensesListController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${Get.find<WalletsListController>().wallets.firstWhere((w) => w.walletId == expense.walletId).currency.code} ${expense.amount.toStringAsFixed(2)}',

          style: const TextStyle(
            color: SpColor.expenseRed,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconBtn(Icons.edit, Colors.blueAccent, () {
              final updateController = Get.find<UpdateExpenseController>();
              updateController.setExpense(expense);
              showUpdateDialog(updateController);
            }),
            const SizedBox(width: 6),
            _iconBtn(Icons.delete, Colors.redAccent, () {
              showDeleteDialog(expense, Get.find<DeleteExpenseController>());
            }),
          ],
        ),
      ],
    );
  }

  // =========================
  // ICON BUTTON
  // =========================

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // =========================
  // UPDATE DIALOG
  // =========================

  void showUpdateDialog(UpdateExpenseController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'تعديل المصروف',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller.titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'العنوان',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: controller.amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'المبلغ',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SpColor.expenseRed,
                      ),
                      onPressed: controller.isLoadingUpdate.value
                          ? null
                          : controller.updateExpense,
                      child: controller.isLoadingUpdate.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'حفظ التعديلات',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // DELETE DIALOG
  // =========================

  void showDeleteDialog(
    ExpenseEntity expense,
    DeleteExpenseController controller,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
                size: 60,
              ),
              const SizedBox(height: 15),
              const Text(
                'حذف المصروف',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'هل تريد حذف هذا المصروف؟',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => controller.deleteExpense(expense),
                      child: const Text('حذف'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
