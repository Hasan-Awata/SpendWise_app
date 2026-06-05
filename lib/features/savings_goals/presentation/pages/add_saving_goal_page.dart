import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_action_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddSavingGoalPage extends GetView<SavingGoalActionController> {
  const AddSavingGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B121E),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'هدف ادخاري جديد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.list_alt_rounded,
              color: SpColor.savinggoalColor,
            ),
            onPressed: () => Get.toNamed(Routes.GOAL_LIST),
          ),
        ],
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ================= CARD =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF162030),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // TITLE
                  CustomTextField(
                    label: 'اسم الهدف',
                    hint: 'مثال: شراء سيارة جديدة',
                    prefixIcon: const Icon(Icons.flag_rounded),
                    textEditingController: controller.titleController,
                    textColor: Colors.white70,
                  ),

                  const SizedBox(height: 16),
                  _buildWalletDropdown(),
                  const SizedBox(height: 16),
                  // TARGET
                  CustomTextField(
                    label: 'المبلغ المستهدف',
                    hint: '0.00',
                    isNumber: true,
                    prefixIcon: const Icon(Icons.flag_circle_outlined),
                    textEditingController: controller.targetAmountController,
                    textColor: Colors.white70,
                  ),

                  const SizedBox(height: 16),

                  // CURRENT
                  CustomTextField(
                    label: 'المبلغ المتوفر (اختياري)',
                    hint: '0.00',
                    isNumber: true,
                    prefixIcon: const Icon(Icons.savings_outlined),
                    textEditingController: controller.currentAmountController,
                    textColor: Colors.white70,
                  ),
                  const SizedBox(height: 20),
                  _buildDatePicker(context),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= BUTTON =================
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: controller.isActionLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: "حفظ الهدف",
                        onPressed: () {
                          controller.addSavingGoal();
                        },
                        color: SpColor.savinggoalColor,
                      ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletDropdown() {
    return Obx(
      () => controller.walletsListController.regularWallets.isEmpty
          ? const Text(
              "لا توجد محافظ متاحة",
              style: TextStyle(color: Colors.white38),
            )
          : SPDropdownSearch(
              themeColor: SpColor.savinggoalColor,
              label: "المحفظة",
              items: controller.walletsListController.regularWallets
                  .map(
                    (w) => "${w.currency.currencyName} (${w.currency.code})",
                  ) // يفضل استخدام `اسم` المحفظة w.name
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = controller.walletsListController.regularWallets
                    .firstWhere(
                      (w) =>
                          "${w.currency.currencyName} (${w.currency.code})" ==
                          value,
                    );
                controller.selectedWallet.value = selected;
              },
              hint: 'اختر محفظة',
            ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            "تاريخ الانتهاء",
            style: TextStyle(color: Colors.white70),
          ), // تم التعديل لـ LastTime
          trailing: Text(
            DateFormat('yyyy-MM-dd').format(controller.deadlineDate.value),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => controller.fetchDate(context),
        ),
      ),
    );
  }
}
