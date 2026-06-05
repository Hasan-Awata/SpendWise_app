// Expense_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/presentation/manager/delete_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/expense/presentation/manager/update_expense_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class ExpenseListView extends GetView<ExpensesListController> {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        centerTitle: true,
        foregroundColor: SpColor.expenseRed,
        title: const Text(
          "المصاريف الشخصية",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SpColor.expenseRed,

        onPressed: () => Get.toNamed(Routes.ADD_EXPENSE),

        icon: const Icon(Icons.add_rounded, color: Colors.white),

        label: const Text(
          "إضافة مصروف",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value && controller.expensesList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: SpColor.expenseRed),
          );
        }

        if (controller.expensesList.isEmpty) {
          return const Center(
            child: Text(
              "لا يوجد دخل حالياً",

              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchExpenses(isRefresh: true),

          child: ListView.builder(
            controller: controller.scrollController,

            physics: const AlwaysScrollableScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),

            itemCount:
                controller.expensesList.length +
                (controller.hasMoreData.value ? 1 : 0),

            itemBuilder: (context, index) {
              if (index < controller.expensesList.length) {
                return _buildExpenseItem(controller.expensesList[index]);
              }

              return const Padding(
                padding: EdgeInsets.all(20),

                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          ),
        );
      }),
    );
  }

  // =========================
  // ITEM
  // =========================

  Widget _buildExpenseItem(ExpenseEntity Expense) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(
          colors: [SpColor.surfaceNavy, SpColor.primaryDark2],
        ),

        border: Border.all(color: Colors.white12),
      ),

      child: Row(
        children: [
          _buildIcon(),

          const SizedBox(width: 16),

          Expanded(child: _buildDetails(Expense)),

          _buildActions(Expense),
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
          expense.title,

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
          synced.value ? "متزامن" : "غير متزامن",

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

  Widget _buildActions(ExpenseEntity Expense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        Text(
          '${Get.find<WalletsListController>().wallets.firstWhere((w) => w.walletId == Expense.walletId).currency.code} ${Expense.amount.toStringAsFixed(2)}',

          style: const TextStyle(
            color: SpColor.expenseRed,

            fontSize: 18,

            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            _iconBtn(Icons.edit, Colors.blueAccent, () {
              final controller = Get.find<UpdateExpenseController>();

              controller.setExpense(Expense);

              showUpdateDialog(controller);
            }),
            const SizedBox(width: 6),

            _iconBtn(Icons.delete, Colors.redAccent, () {
              showDeleteDialog(Expense, Get.find<DeleteExpenseController>());
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
        icon: Icon(icon, color: color, size: 20),

        onPressed: onTap,
      ),
    );
  }

  void showUpdateDialog(UpdateExpenseController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "تعديل المصاريف",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= TITLE =================
                  TextField(
                    controller: controller.titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "العنوان",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================= AMOUNT (READ ONLY) =================
                  Text(
                    "المبلغ: ${controller.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= PRODUCT SECTION =================
                  _buildProductSection(controller),

                  const SizedBox(height: 25),

                  // ================= SAVE BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SpColor.expenseRed,
                      ),
                      onPressed: controller.isLoadingUpdate.value
                          ? null
                          : () => controller.updateExpense(),
                      child: controller.isLoadingUpdate.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "حفظ التعديلات",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProductSection(UpdateExpenseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "المنتجات المشتراة",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // ================= INPUT ROW =================
        Row(
          children: [
            // اسم المنتج
            Expanded(
              flex: 3,
              child: _field(
                "الاسم",
                controller.productNameController,
                Icons.shopping_bag_rounded,
              ),
            ),

            const SizedBox(width: 8),

            // الكمية
            Expanded(
              flex: 2,
              child: _field(
                "الكمية",
                controller.productQuantityController,
                Icons.onetwothree,
                number: true,
              ),
            ),

            const SizedBox(width: 8),

            // السعر
            Expanded(
              flex: 2,
              child: _field(
                "السعر",
                controller.productPriceController,
                Icons.attach_money_rounded,
                number: true,
              ),
            ),

            const SizedBox(width: 8),

            // زر الإضافة
            InkWell(
              onTap: controller.addProductToList,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SpColor.expenseRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ================= PRODUCTS LIST =================
        Obx(() {
          if (controller.tempProducts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "لا توجد منتجات مضافة",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            );
          }

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: controller.tempProducts.map((product) {
              final index = controller.tempProducts.indexOf(product);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${product.name} x${product.quantity} - ${product.price}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),

                    const SizedBox(width: 6),

                    GestureDetector(
                      onTap: () => controller.removeProduct(index),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool number = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: SpColor.expenseRed, size: 18),
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
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
                "حذف المصاريف الشخصية",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "هل تريد حذف هذا المصاريف الشخصية؟",

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),

                      child: const Text("إلغاء"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),

                      onPressed: () {
                        controller.deleteExpense(expense);
                      },

                      child: const Text("حذف"),
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
