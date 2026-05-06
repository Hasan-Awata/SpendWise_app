import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_action_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class AddSavingGoalPage extends GetView<SavingGoalActionController> {
  const AddSavingGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark2,
        elevation: 0,
        title: const Text(
          'هدف ادخار جديد',
          style: TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        // // تعليق: زر ينقل المستخدم إلى قائمة الأهداف المحفوظة في يسار الـ AppBar
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.amberAccent,
            ),
            onPressed: () => Get.toNamed(Routes.GOAL_LIST),
          ),
          const SizedBox(width: 8),
        ],
        iconTheme: const IconThemeData(color: Colors.amberAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'اسم الهدف',
                hint: 'مثال: شراء سيارة جديدة',
                prefixIcon: const Icon(Icons.flag_rounded),
                textEditingController: controller.titleController,
                textColor: Colors.amberAccent.withAlpha(160),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'المبلغ المستهدف',
                hint: '0.00',
                isNumber: true,
                prefixIcon: const Icon(Icons.ads_click),
                textEditingController: controller.targetAmountController,
                textColor: Colors.amberAccent.withAlpha(160),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'المبلغ المتوفر حالياً (اختياري)',
                hint: '0.00',
                isNumber: true,
                prefixIcon: const Icon(Icons.savings_outlined),
                textEditingController: controller.currentAmountController,
                textColor: Colors.amberAccent.withAlpha(160),
              ),
              const SizedBox(height: 32),
              // // تعليق: زر الحفظ مع حالة التحميل لضمان تجربة مستخدم سلسة
              Obx(
                () => CustomButton(
                  text: controller.isActionLoading.value
                      ? "جاري الحفظ..."
                      : "حفظ الهدف",
                  onPressed: () => controller.addSavingGoal(),
                  color: Colors.amberAccent.withAlpha(195),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
