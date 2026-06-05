import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_action_controller.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_lis_controller.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';

class SavingGoalsListPage extends GetView<SavingGoalListController> {
  // Comment: Initializing the action controller to manage saving goal updates and interactions.
  final savingGoalAction = Get.find<SavingGoalActionController>();

  SavingGoalsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Comment: Setting the background color explicitly to avoid white screen flashes during page transitions in release mode.
    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark,
        title: const Text(
          "أهدافي الادخارية",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            color: SpColor.savinggoalColor,
            backgroundColor: SpColor.primaryDark,
            onRefresh: () => controller.loadSavingGoals(isRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.savingGoals.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: SpColor.savinggoalColor,
                      ),
                    );
                  }
                  if (controller.savingGoals.isEmpty) {
                    return const Center(
                      child: Text(
                        "لا توجد أهداف مضافة بعد",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.savingGoals.length,
                      itemBuilder: (context, index) {
                        final goal = controller.savingGoals[index];
                        return _buildGoalCard(goal);
                      },
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _syncStatusBadge(SavingGoalEntity goal) {
    // Comment: Displaying the sync status of the goal to inform the user about data synchronization.
    return Obx(() {
      final bool synced = goal.isSynced.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: synced
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          synced ? "متزامن" : "غير متزامن",
          style: TextStyle(
            color: synced ? Colors.greenAccent : Colors.orangeAccent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }

  Widget _buildGoalCard(SavingGoalEntity goal) {
    // Comment: Calculating progress percentage safely, ensuring no division by zero occurs.
    double progress = (goal.targetAmount > 0)
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    int percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: () => _providingTarger(goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SpColor.primaryDark2,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: SpColor.savinggoalColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      percentage >= 100
                          ? Icons.check_circle
                          : Icons.trending_up,
                      color: SpColor.savinggoalColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      goal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _syncStatusBadge(goal),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                  color: SpColor.surfaceNavy,
                  onSelected: (value) {
                    if (value == 'edit')
                      _showEditSheet(goal);
                    else if (value == 'delete')
                      _showDeleteConfirmation(goal);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                          SizedBox(width: 10),
                          Text("تعديل", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_forever,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text("حذف", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "وفرت: ${goal.currentAmount} ${Get.find<CurrencyLocal>().allCurrencies[goal.currencyId - 1].code}",
                  style: TextStyle(color: Colors.grey[400]),
                ),
                Text(
                  "الهدف: ${goal.targetAmount} ${Get.find<CurrencyLocal>().allCurrencies[goal.currencyId - 1].code}",
                  style: const TextStyle(
                    color: SpColor.savinggoalColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orangeAccent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "$percentage%",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Comment: Added the missing _providingTarger method to handle goal contribution input.
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
                "المبلغ المراد إضافته",
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
                      backgroundColor: SpColor.savinggoalColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      double added =
                          double.tryParse(
                            savingGoalAction.currentAmountController.text,
                          ) ??
                          0.0;
                      savingGoalAction.currentAmountController.text =
                          (added + previousAmount).toString();
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
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSheet(SavingGoalEntity goal) {
    // Comment: Pre-filling the fields before showing the edit bottom sheet to ensure current state is reflected.
    savingGoalAction.titleController.text = goal.title;
    savingGoalAction.targetAmountController.text = goal.targetAmount.toString();
    savingGoalAction.currentAmountController.text = goal.currentAmount
        .toString();
    savingGoalAction.deadlineDate.value = goal.deadlineDate;

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
                "تعديل الهدف",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                savingGoalAction.titleController,
                "عنوان الهدف",
                Icons.title,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                savingGoalAction.targetAmountController,
                "المبلغ المستهدف",
                Icons.flag,
                isNumber: true,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                savingGoalAction.currentAmountController,
                "المبلغ المتوفر حالياً",
                Icons.attach_money,
                isNumber: true,
              ),
              const SizedBox(height: 25),
              _buildDatePicker(Get.context!),
              const SizedBox(height: 25),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpColor.savinggoalColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: savingGoalAction.isActionLoading.value
                        ? null
                        : () => savingGoalAction.updateSavingGoal(goal),
                    child: savingGoalAction.isActionLoading.value
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "حفظ التغييرات",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
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
    // Comment: Creating a clean, reusable input field for editing goal details.
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: SpColor.savinggoalColor, size: 20),
        filled: true,
        fillColor: SpColor.surfaceNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(SavingGoalEntity goal) {
    // Comment: Providing a clear confirmation dialog before performing the deletion operation.
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: SpColor.primaryDark2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "حذف الهدف",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "هل أنت متأكد من رغبتك في حذف هدف '${goal.title}'؟",
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => savingGoalAction.deleteSavingGoal(goal),
                    child: const Text(
                      "حذف الآن",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "إلغاء",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    // Comment: Date picker wrapper for selecting goal deadlines, ensuring consistent theme.
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            "تاريخ الانتهاء",
            style: TextStyle(color: Colors.white70),
          ),
          trailing: Text(
            DateFormat(
              'yyyy-MM-dd',
            ).format(savingGoalAction.deadlineDate.value),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async => await savingGoalAction.fetchDate(context),
        ),
      ),
    );
  }
}
