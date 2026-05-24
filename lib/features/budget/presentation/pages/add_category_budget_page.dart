import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/budget/presentation/manager/add_category_budget_controller.dart';

class ManageCategoryBudgetScreen
    extends GetView<ManageCategoryBudgetController> {
  final int userId;
  final RxDouble localSliderValue = 25.0.obs;

  ManageCategoryBudgetScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // ربط مستمع لتغيير النص في الـ controller لتحديث السلايدر الرسومي تلقائياً عند تغيير الفئة
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
            onPressed: () {
              Get.toNamed(Routes.CATEGORY_BUDGET);
            },
            icon: Icon(Icons.list),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.listController.budgets.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: SpColor.accentBlue),
          );
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. عرض الـ 4 تصنيفات الثابتة مع حالتها الحالية
                _FixedCategoryGrid(controller: controller),
                const SizedBox(height: 30),

                // 2. السلايدر الذكي للتعديل
                _PercentageSliderSection(controller: controller),
                const SizedBox(height: 25),

                // 3. النطاق الزمني للميزانية المحددة
                _DateRangeSection(controller: controller),
                const SizedBox(height: 25),

                // 4. سويتش التفعيل
                _ActivationSwitchSection(controller: controller),
                const SizedBox(height: 40),

                // 5. زر الحفظ الذكي (تعديل أو إضافة)
                _SubmitButton(controller: controller, userId: userId),
              ],
            ),
          ),
        );
      }),
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
          style: TextStyle(
            color: SpColor.mutedGrey,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // وضعنا الـ Obx هنا وسنقوم بالوصول لمتغير .value بالداخل ليختفي الخطأ فوراً
        Obx(() {
          // خدعة ذكية: نقرأ طول القائمة التفاعلية activeBudgets ليتم تسجيل هذا الـ Widget في نظام المراقبة لـ GetX
          final _ = controller.listController.budgets.length;
          final selectedId = controller
              .selectedCategoryId
              .value; // مراقبة التصنيف الحالي أيضاً

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

              IconData categoryIcon = Icons.folder_open_outlined;
              if (item.categoryId == 1)
                categoryIcon = Icons.shopping_cart_outlined;
              if (item.categoryId == 2) categoryIcon = Icons.movie_outlined;
              if (item.categoryId == 3)
                categoryIcon = Icons.card_giftcard_outlined;
              if (item.categoryId == 4) categoryIcon = Icons.savings_outlined;

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            categoryIcon,
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
                            ? "الميزانية الحالية: ${item.budget!.percentageLimit.toStringAsFixed(0)}%"
                            : "لا توجد ميزانية مخصصة",
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

  // تعديل الـ Constructor لاستقبال الـ controller فقط
  const _PercentageSliderSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    // نضع الـ Obx هنا لضمان استماع السلايدر للتغييرات القادمة من الـ controller فور الانتقال بين الفئات
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "النسبة المئوية المخصصة للميزانية",
                  style: TextStyle(
                    color: SpColor.mutedGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
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
            const SizedBox(height: 20),
            SizedBox(
              height: 1,
              child: TextFormField(
                controller: controller.percentageController,
                readOnly: true,
                decoration: const InputDecoration(border: InputBorder.none),
                validator: (value) => (value == null || value.isEmpty)
                    ? "يرجى تحديد النسبة المئوية"
                    : null,
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: controller.sliderValue.value > 60
                    ? SpColor.expenseRed
                    : SpColor.accentBlue,
                inactiveTrackColor: SpColor.primaryDark,
                thumbColor: SpColor.offWhite,
                trackHeight: 6,
              ),
              child: Slider(
                value: controller.sliderValue.value,
                min: 1.0,
                max: 100.0,
                onChanged: (value) {
                  // تحديث القيمتين معاً في الـ controller مباشرة أثناء السحب
                  controller.sliderValue.value = value;
                  controller.percentageController.text = value.toStringAsFixed(
                    0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= تعديل كلاس زر الإدخال السفلي =================
class _SubmitButton extends StatelessWidget {
  final ManageCategoryBudgetController controller;
  final int userId;

  const _SubmitButton({required this.controller, required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentCat = controller.categoryList.firstWhere(
      (c) => c.categoryId == controller.selectedCategoryId.value,
    );
    final isUpdateMode = currentCat.budget != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        // نمرر قيمة السلايدر مباشرة من الـ controller
        onPressed: () =>
            controller.saveOrUpdateBudget(userId, controller.sliderValue.value),
        style: ElevatedButton.styleFrom(
          backgroundColor: isUpdateMode
              ? SpColor.incomeGreen
              : SpColor.accentBlue,
          foregroundColor: SpColor.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
        ),
        child: Text(
          isUpdateMode ? "تحديث ميزانية الفئة" : "حفظ وإدراج الميزانية",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// كلاس النطاق الزمني
class _DateRangeSection extends StatelessWidget {
  final ManageCategoryBudgetController controller;
  const _DateRangeSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildDateTile(
              title: "تاريخ البدء",
              icon: Icons.date_range,
              onTap: () => controller.pickStartDate(context),
              dateStream: controller.startDate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateTile(
              title: "تاريخ الانتهاء",
              icon: Icons.event_available,
              onTap: () => controller.pickEndDate(context),
              dateStream: controller.endDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Rxn<DateTime> dateStream,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: SpColor.accentBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: SpColor.mutedGrey,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStream.value != null
                        ? DateFormat('yyyy/MM/dd').format(dateStream.value!)
                        : "اختر التاريخ",
                    style: const TextStyle(
                      color: SpColor.offWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// كلاس سويتش التفعيل
class _ActivationSwitchSection extends StatelessWidget {
  final ManageCategoryBudgetController controller;
  const _ActivationSwitchSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            "تفعيل الميزانية فوراً",
            style: TextStyle(
              color: SpColor.offWhite,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            "سيتم احتساب ميزانية الفئة في الإحصاءات فور الحفظ",
            style: TextStyle(color: SpColor.mutedGrey, fontSize: 11),
          ),
          value: controller.isActive.value,
          activeThumbColor: SpColor.incomeGreen,
          inactiveTrackColor: SpColor.primaryDark,
          onChanged: (bool value) => controller.isActive.value = value,
        ),
      ),
    );
  }
}
