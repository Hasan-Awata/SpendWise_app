// add_expense_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/manager/add_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/widgets/tag_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field_description.dart';
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
                    _modernField(
                      label: "عنوان المصروف",
                      controller: controller.titleTextController,
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 18),
                    _modernField(
                      label: "المبلغ",
                      controller: controller.amountController,
                      icon: Icons.attach_money_rounded,
                      number: true,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _sectionCard(children: [_buildCategoryDropdown()]),

                const SizedBox(height: 18),

                _sectionCard(children: [_buildProductSection()]),

                const SizedBox(height: 18),

                _buildFixedExpenseSection(),

                const SizedBox(height: 18),

                _sectionCard(
                  children: [
                    CustomTextFieldDescription(
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

  Widget _sectionCard({required List<Widget> children}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _modernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool number = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF15A5A).withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFF15A5A)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFixedExpenseSection() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: controller.isFixed.value
                      ? [const Color(0xFFF15A5A), const Color(0xFFFF8C8C)]
                      : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: controller.isFixed.value
                        ? Colors.red.withOpacity(0.2)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.isFixed.value,
                activeThumbColor: Colors.white,
                onChanged: (v) {
                  controller.isFixed.value = v;
                },
                title: const Text(
                  "مصروف ثابت",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    "سيتم تكراره تلقائياً",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: controller.isFixed.value
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _sectionCard(
                        children: [
                          _modernField(
                            label: "التكرار بالأيام",
                            controller: controller.repeatController,
                            icon: Icons.repeat_rounded,
                            number: true,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: controller.isLoadingSave.value
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(color: Color(0xFFF15A5A)),
              )
            : SizedBox(
                width: double.infinity,
                height: 58,
                child: CustomButton(
                  text: "حفظ المصروف",
                  onPressed: controller.saveExpense,
                  color: const Color(0xFFF15A5A),
                ),
              ),
      ),
    );
  }

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

  Widget _buildProductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "المنتجات",
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
              child: _modernField(
                label: "أدخل منتج",
                controller: controller.productsController,
                icon: Icons.shopping_bag_rounded,
              ),
            ),

            const SizedBox(width: 10),

            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: controller.addProductToList,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFF15A5A),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: controller.tempProducts
                .map(
                  (product) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Chip(
                      label: Text(
                        product,
                        style: const TextStyle(
                          color: SpColor.expenseRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: SpColor.surfaceNavy,
                      deleteIconColor: SpColor.expenseRed,
                      onDeleted: () {
                        controller.removeProduct(product);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
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

  Widget _buildWalletDropdown() {
    return Obx(
      () => SPDropdownSearch(
        themeColor: SpColor.expenseRed,
        label: "المحفظة",
        items: controller.walletsListController.wallets
            .map((w) => "${w.currency.currencyName} (${w.currency.code})")
            .toList(),
        onChanged: (value) {
          final index = controller.walletsListController.wallets.indexWhere(
            (w) => "${w.currency.currencyName} (${w.currency.code})" == value,
          );

          if (index != -1) {
            controller.selectedWallet.value =
                controller.walletsListController.wallets[index];
          }
        },
        hint: "اختر محفظة",
      ),
    );
  }

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
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: controller.selectedTag.value != null
            ? TagWidget(
                tagName: controller.selectedTag.value!.name,
                icon: Icons.check_circle_rounded,
                color: const Color(0xFFF15A5A),
                onDelete: () {
                  controller.selectedTag.value = null;
                },
              )
            : const SizedBox(),
      ),
    );
  }
}
