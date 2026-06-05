import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/debts/presentation/manager/debts_list_controller.dart';
import 'package:spendwise/features/debts/presentation/manager/delete_debt_controller.dart';
import 'package:spendwise/features/debts/presentation/manager/update_debt_controller.dart';

class SharedDebtsView extends StatelessWidget {
  SharedDebtsView({super.key});

  final controller = Get.find<DebtsListController>();
  final deleteController = Get.find<DeleteDebtController>();
  final updateController = Get.find<UpdateDebtController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: SpColor.accentBlue,
        centerTitle: true,
        title: const Text(
          "الديون",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () => controller.fetchAllDebts(isRefresh: true),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: SpColor.accentBlue),
            );
          }

          if (controller.debts.isEmpty) {
            return const Center(
              child: Text(
                "لا توجد ديون",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            controller: controller.scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.debts.length,
            itemBuilder: (context, index) {
              final debt = controller.debts[index];

              final isPaid = debt.status.toLowerCase() == "paid";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: isPaid
                        ? [Colors.green.shade900, Colors.green.shade700]
                        : [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                ),

                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isPaid
                          ? Colors.green
                          : SpColor.accentBlue,
                      child: Icon(
                        isPaid ? Icons.check : Icons.account_balance_wallet,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "المبلغ: ${debt.amount}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "الحالة: ${debt.status}",
                            style: TextStyle(
                              color: isPaid
                                  ? Colors.greenAccent
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      children: [
                        Text(
                          debt.amount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _showDebtDialog(context, debt, true),
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // زر الحذف
                            IconButton(
                              onPressed: () =>
                                  _showDebtDialog(context, debt, false),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: SpColor.accentBlue,
        onPressed: () => Get.back(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDebtDialog(BuildContext context, dynamic debt, bool isEdit) {
    if (isEdit) {
      // تهيئة البيانات في الـ Controller قبل فتح الـ Dialog
      updateController.setDebt(debt);
    }

    Get.defaultDialog(
      title: isEdit ? "تعديل الدين" : "حذف الدين",
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: const Color(0xFF1E293B),
      radius: 18,
      content: isEdit
          ? Column(
              children: [
                TextField(
                  controller: updateController
                      .titleController, // ربط بـ Controller التعديل
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "اسم الدين",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: updateController
                      .amountController, // ربط بـ Controller التعديل
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "المبلغ",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            )
          : Text(
              "هل أنت متأكد من حذف ${debt.title}؟",
              style: const TextStyle(color: Colors.white70),
            ),

      confirm: Obx(
        () => ElevatedButton(
          // استخدام Obx لعرض مؤشر التحميل
          style: ElevatedButton.styleFrom(
            backgroundColor: isEdit ? SpColor.accentBlue : Colors.redAccent,
          ),
          onPressed: isEdit
              ? (updateController.isLoadingUpdate.value
                    ? null
                    : () => updateController.updateDebt())
              : (deleteController.isLoadingDelete.value
                    ? null
                    : () => deleteController.deleteDebt(debt)),
          child:
              (isEdit
                  ? updateController.isLoadingUpdate.value
                  : deleteController.isLoadingDelete.value)
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  isEdit ? "حفظ التعديلات" : "حذف",
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("إلغاء", style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
