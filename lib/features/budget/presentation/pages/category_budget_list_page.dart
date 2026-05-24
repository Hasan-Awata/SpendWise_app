import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';
import 'package:spendwise/features/budget/presentation/manager/add_category_budget_controller.dart';
import 'package:spendwise/features/budget/presentation/manager/category_budget_list_controller.dart';
import 'package:spendwise/features/budget/presentation/manager/delete_category_budget_controller.dart';

class CategoryBudgetListPage extends GetView<CategoryBudgetListController> {
  const CategoryBudgetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SpColor.surfaceNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: SpColor.offWhite),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: SpColor.primaryDark,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(Routes.ADD_CATEGORY_BUDGET);
        },
        backgroundColor: SpColor.accentBlue,
        foregroundColor: SpColor.primaryDark,
        icon: const Icon(Icons.add, fontWeight: FontWeight.bold),
        label: const Text(
          "إدارة الميزانيات",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                color: SpColor.surfaceNavy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    "ميزانيات الأقسام",
                    style: TextStyle(
                      color: SpColor.offWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "قم بإدارة حدود الإنفاق لكل قسم وتتبع استهلاكك",
                    style: TextStyle(color: SpColor.mutedGrey, fontSize: 15),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: SpColor.accentBlue),
                  );
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value!,
                      style: const TextStyle(
                        color: SpColor.expenseRed,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                if (controller.budgets.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا توجد ميزانيات مدرجة حالياً",
                      style: TextStyle(
                        fontSize: 18,
                        color: SpColor.mutedGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.loadBudgets(isRefresh: true);
                  },
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.budgets.length,
                    itemBuilder: (_, index) {
                      return _BudgetCard(budget: controller.budgets[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final CategoryBudgetEntity budget;

  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final double calculatedProgress = budget.moneyLimit > 0
        ? (budget.spendingProgress / budget.moneyLimit).clamp(0.0, 1.0)
        : 0.0;

    final double remainingMoney = budget.moneyLimit - budget.spendingProgress;

    String categoryName = "قسم غير معروف";
    IconData categoryIcon = Icons.folder_open_rounded;
    Color categoryColor = SpColor.accentBlue;

    switch (budget.categoryId) {
      case 1:
        categoryName = "Essentials";
        categoryIcon = Icons.shopping_cart_outlined;
        categoryColor = SpColor.incomeGreen;
        break;
      case 2:
        categoryName = "Secondaries";
        categoryIcon = Icons.movie_outlined;
        categoryColor = SpColor.accentBlue;
        break;
      case 3:
        categoryName = "Luxuries";
        categoryIcon = Icons.card_giftcard_outlined;
        categoryColor = SpColor.expenseRed;
        break;
      case 4:
        categoryName = "Savings";
        categoryIcon = Icons.savings_outlined;
        categoryColor = SpColor.savinggoalColor;
        break;
    }

    return GestureDetector(
      onTap: () {
        if (Get.isRegistered<ManageCategoryBudgetController>()) {
          final manageController = Get.find<ManageCategoryBudgetController>();
          manageController.selectedCategoryId.value = budget.categoryId;
          manageController.updateFieldsForSelectedCategory();
        }
        Get.toNamed(Routes.ADD_CATEGORY_BUDGET);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: SpColor.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: SpColor.offWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              budget.isActive ? "نشطة" : "متوقفة",
                              style: TextStyle(
                                color: budget.isActive
                                    ? SpColor.incomeGreen
                                    : SpColor.expenseRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _syncStatus(budget.isSynced),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: SpColor.primaryDark,
                    icon: const Icon(Icons.more_vert, color: SpColor.mutedGrey),
                    onSelected: (action) {
                      if (action == "delete") {
                        _showDeleteDialog(context, budget);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: "delete",
                        child: Text(
                          "حذف",
                          style: TextStyle(
                            color: SpColor.expenseRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(
                    title: "الحد المالي",
                    value: "${budget.moneyLimit.toStringAsFixed(0)} ل.س",
                  ),
                  _InfoItem(
                    title: "المستهلك",
                    value: "${budget.spendingProgress.toStringAsFixed(0)} ل.س",
                  ),
                  _InfoItem(
                    title: "المتبقي",
                    value: "${remainingMoney.toStringAsFixed(0)} ل.س",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: calculatedProgress,
                  minHeight: 10,
                  backgroundColor: SpColor.primaryDark,
                  valueColor: AlwaysStoppedAnimation(
                    calculatedProgress >= 0.85
                        ? SpColor.expenseRed
                        : SpColor.accentBlue,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: SpColor.mutedGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${DateFormat('yyyy/MM/dd').format(budget.startDate)}  →  ${DateFormat('yyyy/MM/dd').format(budget.endDate)}",
                    style: const TextStyle(
                      color: SpColor.mutedGrey,
                      fontWeight: FontWeight.w500,
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

  void _showDeleteDialog(
    BuildContext context,
    CategoryBudgetEntity currentBudget,
  ) {
    final deleteController = Get.find<DeleteCategoryBudgetController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: SpColor.surfaceNavy,
        title: const Text(
          "تأكيد الحذف",
          style: TextStyle(
            color: SpColor.offWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "هل أنت متأكد من رغبتك في حذف ميزانية هذه الفئة بشكل نهائي؟",
          style: TextStyle(color: SpColor.mutedGrey),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "إلغاء",
              style: TextStyle(color: SpColor.mutedGrey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await deleteController.deleteBudget(currentBudget);
            },
            child: const Text(
              "حذف",
              style: TextStyle(
                color: SpColor.expenseRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: SpColor.mutedGrey, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: SpColor.offWhite,
          ),
        ),
      ],
    );
  }
}
