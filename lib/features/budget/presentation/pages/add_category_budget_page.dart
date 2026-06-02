import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/budget/presentation/manager/add_category_budget_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class ManageCategoryBudgetScreen extends StatelessWidget {
  final int userId;
  final RxDouble localSliderValue = 25.0.obs;

  final ManageCategoryBudgetController controller = Get.put(
    ManageCategoryBudgetController(updateBudgetUseCase: Get.find()),
  );

  ManageCategoryBudgetScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    ever(controller.selectedCategoryId, (_) {
      localSliderValue.value =
          double.tryParse(controller.percentageController.text) ?? 25.0;
    });

    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark,
        elevation: 0,
        title: const Text(
          "إدارة ميزانيات التصنيفات",
          style: TextStyle(
            color: SpColor.offWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.CATEGORY_BUDGET),
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FixedCategoryGrid(controller: controller),
              const SizedBox(height: 30),
              _PercentageSliderSection(controller: controller),
              const SizedBox(height: 25),
              _DateRangeSection(controller: controller),
              const SizedBox(height: 25),
              _ActivationSwitchSection(controller: controller),
              const SizedBox(height: 40),
              _SubmitButton(controller: controller, userId: userId),
            ],
          ),
        ),
      ),
    );
  }
}

class _FixedCategoryGrid extends StatelessWidget {
  final ManageCategoryBudgetController controller;
  const _FixedCategoryGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "اختر الفئة لمعاينتها أو التعديل عليها",
          style: TextStyle(color: SpColor.mutedGrey, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final _ = controller.listController.budgets.length;
          final selectedId = controller.selectedCategoryId.value;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemCount: controller.categoryList.length,
            itemBuilder: (context, index) {
              final item = controller.categoryList[index];
              final isSelected = selectedId == item.categoryId;
              final hasBudget = item.budget != null;

              IconData icon = Icons.folder_open_outlined;
              if (item.categoryId == 1) icon = Icons.shopping_cart_outlined;
              if (item.categoryId == 2) icon = Icons.movie_outlined;
              if (item.categoryId == 3) icon = Icons.card_giftcard_outlined;
              if (item.categoryId == 4) icon = Icons.savings_outlined;

              return GestureDetector(
                onTap: () =>
                    controller.selectedCategoryId.value = item.categoryId,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SpColor.surfaceNavy
                        : SpColor.surfaceNavy.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? SpColor.accentBlue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            icon,
                            color: isSelected
                                ? SpColor.accentBlue
                                : SpColor.mutedGrey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.name,
                            style: TextStyle(
                              color: isSelected
                                  ? SpColor.offWhite
                                  : SpColor.mutedGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasBudget
                            ? "الميزانية: ${item.budget!.percentageLimit.toStringAsFixed(0)}%"
                            : "لا توجد ميزانية",
                        style: TextStyle(
                          color: hasBudget
                              ? SpColor.incomeGreen
                              : SpColor.mutedGrey.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class _PercentageSliderSection extends StatelessWidget {
  final ManageCategoryBudgetController controller;
  const _PercentageSliderSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // حساب هل المجموع تجاوز الـ 100%
      final total = controller.totalPercentage;
      final isOverLimit = total > 100;
      if (controller.listController.isLoading.value) {
        return HelperFunction.buildShimmer(height: 150);
      }
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "النسبة المئوية المخصصة",
                  style: TextStyle(color: SpColor.mutedGrey),
                ),
                Text(
                  "${controller.sliderValue.value.toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: SpColor.accentBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              activeColor: controller.isOverLimit.value
                  ? SpColor.expenseRed
                  : SpColor.accentBlue,
              value: controller.sliderValue.value,
              min: 1.0,
              max: 100.0,
              onChanged: (value) {
                final currentOthersTotal =
                    controller.totalPercentage - controller.sliderValue.value;
                final maxAllowed = 100.0 - currentOthersTotal;

                if (value <= maxAllowed) {
                  controller.sliderValue.value = value;
                  controller.percentageController.text = value.toStringAsFixed(
                    0,
                  );
                } else {
                  controller.sliderValue.value = maxAllowed;
                  controller.percentageController.text = maxAllowed
                      .toStringAsFixed(0);
                }

                // تحديث الـ Flag بعد كل حركة
                controller.isOverLimit.value =
                    controller.totalPercentage > 100.01;
              },
            ),
            // إضافة نص المجموع التفاعلي
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "إجمالي الميزانيات: ${controller.totalPercentage.toStringAsFixed(0)}%",
                style: TextStyle(
                  color: controller.isOverLimit.value
                      ? SpColor.expenseRed
                      : SpColor.mutedGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (controller.isOverLimit.value) // استخدام الـ Flag هنا فقط
              const Text(
                "تحذير: لا يمكن تجاوز 100%",
                style: TextStyle(color: SpColor.expenseRed),
              ),
          ],
        ),
      );
    });
  }
}

class _DateRangeSection extends StatelessWidget {
  final ManageCategoryBudgetController controller;
  const _DateRangeSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.listController.isLoading.value
          ? Row(
              // Shimmer موازي لشكل الـ Row
              children: [
                Expanded(child: HelperFunction.buildShimmer(height: 80)),
                const SizedBox(width: 12),
                Expanded(child: HelperFunction.buildShimmer(height: 80)),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildTile(
                    "تاريخ البدء",
                    Icons.date_range,
                    () => controller.pickStartDate(context),
                    controller.startDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTile(
                    "تاريخ الانتهاء",
                    Icons.event_available,
                    () => controller.pickEndDate(context),
                    controller.endDate,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTile(
    String title,
    IconData icon,
    VoidCallback onTap,
    Rxn<DateTime> date,
  ) {
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SpColor.surfaceNavy,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: SpColor.accentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Icon(icon, color: SpColor.accentBlue, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    date.value != null
                        ? DateFormat('yyyy/MM/dd').format(date.value!)
                        : "اختر التاريخ",
                    style: const TextStyle(
                      color: SpColor.offWhite,
                      fontWeight: FontWeight.bold,
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

class _SubmitButton extends StatelessWidget {
  final ManageCategoryBudgetController controller;
  final int userId;
  const _SubmitButton({required this.controller, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        // نتحقق من حالة التحميل أو المجموع الخاطئ
        if (controller.isLoading.value) {
          return CircularProgressIndicator(color: SpColor.incomeGreen);
        }

        final currentCat =
            controller.selectedCategory; // استخدمنا الـ Getter المحدث
        final isUpdate = currentCat.budget != null;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            // تعطيل الزر إذا كان المجموع أكبر من 100
            onPressed: controller.isOverLimit.value
                ? null
                : () => controller.saveOrUpdateBudget(
                    userId,
                    controller.sliderValue.value,
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isOverLimit.value
                  ? SpColor.mutedGrey
                  : (isUpdate ? SpColor.incomeGreen : SpColor.accentBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(isUpdate ? "تحديث الميزانية" : "حفظ الميزانية"),
          ),
        );
      }),
    );
  }
}

class _ActivationSwitchSection extends StatelessWidget {
  final ManageCategoryBudgetController controller;
  const _ActivationSwitchSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.listController.isLoading.value)
        return HelperFunction.buildShimmer(height: 70);

      return Container(
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: controller.isActive.value
                ? SpColor.accentBlue.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: SwitchListTile(
          activeThumbColor: SpColor.accentBlue,
          activeTrackColor: SpColor.accentBlue.withOpacity(0.4),
          inactiveThumbColor: SpColor.mutedGrey,
          inactiveTrackColor: SpColor.primaryDark,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          title: const Text(
            "تفعيل الميزانية",
            style: TextStyle(
              color: SpColor.offWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            controller.isActive.value
                ? "الميزانية مفعلة حالياً"
                : "الميزانية معطلة",
            style: TextStyle(
              color: controller.isActive.value
                  ? SpColor.accentBlue
                  : SpColor.mutedGrey,
              fontSize: 12,
            ),
          ),
          value: controller.isActive.value,
          onChanged: (v) => controller.isActive.value = v,
        ),
      );
    });
  }
}
