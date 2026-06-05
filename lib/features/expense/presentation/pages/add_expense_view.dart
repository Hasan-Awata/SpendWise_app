// add_expense_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/manager/add_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/widgets/tag_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddExpenseView extends GetView<AddExpenseController> {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF020817),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            "مصروف جديد",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Get.toNamed(Routes.LIST_EXPENSE),
              icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _sectionCard(
                  children: [
                    _field(
                      "عنوان المصروف",
                      controller.titleTextController,
                      Icons.title_rounded,
                    ),
                    const SizedBox(height: 18),
                    // // ميزة: استبدال حقل الإدخال اليدوي بحاكي رقمي ذكي يقرأ المجموع تلقائياً من قائمة المنتجات المضافة
                    _buildLiveTotalAmountTile(),
                  ],
                ),

                const SizedBox(height: 18),

                _sectionCard(children: [_buildCategoryDropdown()]),

                const SizedBox(height: 18),

                _sectionCard(children: [_buildProductSection()]),

                const SizedBox(height: 18),

                _sectionCard(
                  children: [
                    CustomTextField(
                      label: "الوصف",
                      hint: "تفاصيل إضافية...",
                      textEditingController: controller.descriptionController,
                      textColor: const Color(0xFFF15A5A),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _sectionCard(children: [_buildDatePicker()]),

                const SizedBox(height: 18),

                _sectionCard(children: [_buildWalletDropdown()]),

                const SizedBox(height: 18),

                _sectionCard(
                  children: [
                    _buildTagDropdown(),
                    const SizedBox(height: 14),
                    _buildTagPreview(),
                  ],
                ),

                const SizedBox(height: 30),

                _buildSaveButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // // تعليق: بطاقة عرض المجموع المباشر المحسوب برمجياً لمنع التلاعب بالأرقام المتسببة بأخطاء السيرفر
  Widget _buildLiveTotalAmountTile() {
    return Obx(() {
      final total = controller.totalCalculatedAmount.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: total > 0
                ? SpColor.expenseRed.withOpacity(0.3)
                : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate_rounded,
                  color: total > 0 ? SpColor.expenseRed : Colors.white38,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  "المبلغ الإجمالي المالي:",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: total > 0 ? SpColor.expenseRed : Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              child: Text("\$${total.toStringAsFixed(2)}"),
            ),
          ],
        ),
      );
    });
  }

  // =====================================================
  // PRODUCT SECTION (NEW SPLIT FIELDS UI)
  // =====================================================
  Widget _buildProductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "المنتجات المشتراة",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: _field(
                "الاسم",
                controller.productNameController,
                Icons.shopping_bag_rounded,
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              flex: 2,
              child: _field(
                "الكمية",
                controller.productQuantityController,
                Icons.production_quantity_limits_rounded,
                number: true,
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              flex: 2,
              child: _field(
                "السعر",
                controller.productPriceController,
                Icons.attach_money_rounded,
                number: true,
              ),
            ),
            const SizedBox(width: 10),

            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (controller.productNameController.text.trim().isNotEmpty) {
                  controller.addProductToList();
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFF15A5A),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Obx(
          () => controller.tempProducts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white38,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "يرجى إضافة منتج واحد على الأقل لتحديد تكلفة المصروف.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(controller.tempProducts.length, (
                    index,
                  ) {
                    final product = controller.tempProducts[index];
                    final displayText =
                        "${product.name} (x${product.quantity}) - \$${product.price}";

                    return Chip(
                      label: Text(
                        displayText,
                        style: const TextStyle(
                          color: SpColor.expenseRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: SpColor.surfaceNavy,
                      deleteIconColor: SpColor.expenseRed,
                      onDeleted: () {
                        controller.removeProduct(index);
                      },
                    );
                  }),
                ),
        ),
      ],
    );
  }

  // =====================================================
  // SAVE BUTTON
  // =====================================================
  Widget _buildSaveButton() {
    return Obx(
      () => controller.isLoadingSave.value
          ? const CircularProgressIndicator(color: Color(0xFFF15A5A))
          : SizedBox(
              width: double.infinity,
              height: 58,
              child: CustomButton(
                text: "حفظ المصروف",
                onPressed: controller.saveExpense,
                color: const Color(0xFFF15A5A),
              ),
            ),
    );
  }

  // =====================================================
  // CATEGORY
  // =====================================================
  Widget _buildCategoryDropdown() {
    return Obx(
      () => SPDropdownSearch(
        themeColor: const Color(0xFFF15A5A),
        label: "الفئة",
        items: controller.categories.map((e) => e.name).toList(),
        selectedItem: controller.selectedCategory.value?.name,
        onChanged: (value) {
          controller.selectedCategory.value = controller.categories
              .firstWhereOrNull((e) => e.name == value);
        },
        hint: "اختر تصنيف",
      ),
    );
  }

  // =====================================================
  // WALLET
  // =====================================================
  Widget _buildWalletDropdown() {
    return Obx(
      () => SPDropdownSearch(
        themeColor: SpColor.expenseRed,
        label: "المحفظة",
        items: controller.walletsListController.regularWallets
            .map((w) => "${w.currency.currencyName} (${w.currency.code})")
            .toList(),
        onChanged: (value) {
          final index = controller.walletsListController.regularWallets
              .indexWhere(
                (w) =>
                    "${w.currency.currencyName} (${w.currency.code})"
                        .toLowerCase()
                        .trim() ==
                    value?.toLowerCase().trim(),
              );

          if (index != -1) {
            controller.selectedWallet.value =
                controller.walletsListController.regularWallets[index];
          }
        },
        hint: "اختر محفظة",
      ),
    );
  }

  // =====================================================
  // TAG
  // =====================================================
  Widget _buildTagDropdown() {
    return Obx(
      () => SPDropdownSearch(
        themeColor: SpColor.expenseRed,
        label: "الوسم",
        items: controller.tagController.myTags.map((e) => e.name).toList(),
        onChanged: (value) {
          controller.tagTextController.text = value ?? "";
          controller.selectedTag.value = controller.tagController.myTags
              .firstWhereOrNull((e) => e.name == value);
        },
        hint: "اختر وسم",
      ),
    );
  }

  Widget _buildTagPreview() {
    return Obx(
      () => controller.selectedTag.value != null
          ? TagWidget(
              tagName: controller.selectedTag.value!.name,
              icon: Icons.check_circle_rounded,
              color: const Color(0xFFF15A5A),
              onDelete: () => controller.selectedTag.value = null,
            )
          : const SizedBox(),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================
  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: const Color(0xFF1E293B),
      ),
      child: Column(children: children),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctr,
    IconData icon, {
    bool number = false,
  }) {
    return TextField(
      controller: ctr,
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

  Widget _buildDatePicker() {
    return Obx(
      () => DatePickerWidget(
        onTap: () => controller.fetchDate(Get.context!),
        selectedDate: controller.selectedDate.value,
        color: const Color(0xFFF15A5A),
      ),
    );
  }
}
