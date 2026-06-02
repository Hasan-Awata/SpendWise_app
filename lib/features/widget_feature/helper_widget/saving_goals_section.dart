// // [تعديل واجهة الأهداف الادخارية لتعرض التقدم الفعلي والبيانات من الموديل المحدث]
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ والعملة
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_action_controller.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_lis_controller.dart';

class SavingsGoalsSection extends StatefulWidget {
  const SavingsGoalsSection({super.key});

  @override
  State<SavingsGoalsSection> createState() => _SavingsGoalsSectionState();
}

class _SavingsGoalsSectionState extends State<SavingsGoalsSection> {
  final controller = Get.find<SavingGoalListController>();
  final savingGoalAction = Get.find<SavingGoalActionController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "الأهداف الادخارية",
              style: TextStyle(
                color: SpColor.offWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(Routes.GOAL_LIST),
              child: const Text(
                "عرض الكل",
                style: TextStyle(color: Colors.amber, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => (controller.isLoading.value)
              ? CircularProgressIndicator(color: SpColor.savinggoalColor)
              : SizedBox(
                  height: 140, // تم زيادة الارتفاع ليتناسب مع التصميم الجديد
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.savingGoals.length,
                    itemBuilder: (context, index) {
                      final goal = controller.savingGoals[index];
                      return _buildEnhancedGoalCard(goal);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // // [بناء كرت الهدف المحسن مع حسابات التقدم الدقيقة]
  Widget _buildEnhancedGoalCard(SavingGoalEntity goal) {
    // حساب النسبة المئوية للتقدم
    double progressValue = (goal.currentAmount / goal.targetAmount).clamp(
      0.0,
      1.0,
    );
    int percentage = (progressValue * 100).toInt();

    // اختيار اللون بناءً على حالة المزامنة أو نسبة التقدم
    Color statusColor = percentage >= 100 ? Colors.greenAccent : Colors.amber;

    return GestureDetector(
      onTap: () => _providingTarger(goal),
      child: Container(
        width: 180, // عرض أكبر قليلاً للوضوح
        margin: const EdgeInsets.only(right: 15, bottom: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SpColor.offWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (!goal.isSynced.value)
                  const Icon(
                    Icons.sync_problem,
                    size: 14,
                    color: Colors.redAccent,
                  ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progressValue,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusColor, statusColor.withOpacity(0.6)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$percentage%",
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
                Text(
                  DateFormat('MMM dd').format(goal.deadlineDate),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _providingTarger(SavingGoalEntity goal) {
    savingGoalAction.titleController.text = goal.title;

    savingGoalAction.targetAmountController.text = goal.targetAmount.toString();
    savingGoalAction.currentAmountController.text = goal.currentAmount
        .toString();
    savingGoalAction.deadlineDate.value = goal.deadlineDate;

    double previousAmount = goal.currentAmount;

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: SpColor.primaryDark2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "تزويد الهدف الادخاري",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),
              _buildTextField(
                savingGoalAction.currentAmountController,
                "المبلغ المتوفر حالياً",
                Icons.attach_money,
                isNumber: true,
              ),
              const SizedBox(height: 25),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      savingGoalAction.currentAmountController.text =
                          (double.parse(
                                    savingGoalAction
                                        .currentAmountController
                                        .text,
                                  ).toDouble() +
                                  previousAmount)
                              .toString();
                      savingGoalAction.updateSavingGoal(goal);
                    },
                    child: savingGoalAction.isActionLoading.value
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "تزويد الهدف",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.amberAccent, size: 20),
        filled: true,
        fillColor: SpColor.surfaceNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
