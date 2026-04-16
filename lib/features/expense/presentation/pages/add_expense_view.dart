// // تعليق: واجهة إضافة مصروف - مدمجة مع نظام المزامنة والتحقق المطور
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/manager/add_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/widgets/tag_widget.dart';

import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field_description.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddExpenseView extends StatefulWidget {
  AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  @override
  void initState() {
    super.initState();
    controller.walletsListController.loadWallets();
    controller.tagController.loadTags();
  }

  final controller = Get.find<AddExpenseController>();

  final RxBool isFixed = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: const Color(0xFFF15A5A),
        onRefresh: () async {
          controller.resetFields();
          await controller.walletsListController.loadWallets();
          await controller.tagController.loadTags();
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // // UI: حقل العنوان (Title/Source)
                  _buildField(
                    "Expense Title",
                    controller.titleTextController,
                    Icons.title,
                    hint: "e.g. Grocery, Rent...",
                  ),
                  const SizedBox(height: 20),

                  // // UI: حقل المبلغ
                  _buildField(
                    "Amount (SAR)",
                    controller.amountController,
                    Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),

                  // // UI: اختيار الـ Category
                  _buildCategoryDropdown(),

                  const SizedBox(height: 25),
                  _buildFixedToggle(),
                  const SizedBox(height: 15),
                  _buildRepetitionField(),

                  const SizedBox(height: 25),
                  CustomTextFieldDescription(
                    label: "Description",
                    hint: "Expense details...",
                    textEditingController: controller.descriptionController,
                    textColor: const Color(0xFFF15A5A),
                  ),

                  const SizedBox(height: 25),
                  _buildDatePicker(context),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 30),

                  _buildWalletDropdown(),
                  const SizedBox(height: 25),

                  // // UI: حقل التاج (يدعم الكتابة لإنشاء تاج جديد تلقائياً)
                  _buildTagDropdown(),
                  const SizedBox(height: 15),
                  _buildTagPreview(),

                  const SizedBox(height: 50),
                  _buildSubmitButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets ---
  PreferredSizeWidget _buildAppBar() => AppBar(
    title: const Text(
      "New Expense",
      style: TextStyle(color: Color(0xFFF15A5A), fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.transparent,
    foregroundColor: const Color(0xFFF15A5A),
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: () => Get.toNamed(Routes.LIST_EXPENSE),
        icon: const Icon(Icons.list),
      ),
    ],
  );

  Widget _buildField(
    String label,
    TextEditingController ctr,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String hint = "...",
  }) => CustomTextField(
    textColor: const Color(0xFFF15A5A),
    label: label,
    hint: hint,
    prefixIcon: Icon(icon, color: const Color(0xFFF15A5A)),
    textEditingController: ctr,
  );

  Widget _buildCategoryDropdown() {
    return Obx(
      () => SPDropdownButton(
        title: "Category",
        hint: "Select expense category",
        textColor: const Color(0xFFF15A5A),
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: Color(0xFFF15A5A),
        ),
        values: controller.categories
            .map((c) => "${c.name} (P${c.priority})")
            .toList(),
        textEditingController: controller.categoryTextController,
      ),
    );
  }

  Widget _buildFixedToggle() => Obx(
    () => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF15A5A).withOpacity(0.5)),
      ),
      child: SwitchListTile(
        title: const Text(
          "Fixed Monthly Expense",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        activeColor: const Color(0xFFF15A5A),
        value: isFixed.value,
        onChanged: (v) {
          isFixed.value = v;
          if (!v) controller.repeatController.clear();
        },
      ),
    ),
  );

  Widget _buildRepetitionField() => Obx(
    () => isFixed.value
        ? _buildField(
            "Repeat Every (Days)",
            controller.repeatController,
            Icons.calendar_month,
            keyboardType: TextInputType.number,
          )
        : const SizedBox.shrink(),
  );

  Widget _buildDatePicker(BuildContext context) => Obx(
    () => DatePickerWidget(
      onTap: () => controller.fetchDate(context),
      selectedDate: controller.selectedDate.value,
      color: const Color(0xFFF15A5A),
    ),
  );

  Widget _buildWalletDropdown() {
    return SPDropdownButton(
      title: "Select Wallet",
      hint: "Choose wallet",
      textColor: const Color(0xFFF15A5A),
      prefixIcon: const Icon(Icons.wallet, color: const Color(0xFFF15A5A)),
      values: controller.walletsListController.wallets
          .map(
            (w) =>
                "${w.currency.currencyName}      (${w.currency.code} ${w.balance})",
          )
          .toList(),
      textEditingController: controller.walletTextController,
      suffixIcon: IconButton(
        onPressed: () async {
          await Get.toNamed('/add-wallet');
          await controller.walletsListController.loadWallets();
        },
        icon: const Icon(Icons.add, color: const Color(0xFFF15A5A)),
      ),
    );
  }

  Widget _buildTagDropdown() => Obx(
    () => SPDropdownButton(
      title: "Select Tag",
      isTextField: true, // تفعيل الكتابة لتمكين ميزة إنشاء تاج جديد تلقائياً
      hint: "Search/Type Tag",
      textColor: const Color(0xFFF15A5A),
      prefixIcon: const Icon(Icons.tag, color: Color(0xFFF15A5A)),
      values: controller.tagController.myTags.map((t) => t.name).toList(),
      textEditingController: controller.tagTextController,
    ),
  );

  Widget _buildTagPreview() => Obx(
    () => controller.selectedTag.value != null
        ? TagWidget(
            tagName: controller.selectedTag.value!.name,
            icon: Icons.check,
            color: const Color(0xFFF15A5A),
            onDelete: () {
              controller.selectedTag.value = null;
              controller.tagTextController.clear();
            },
          )
        : const SizedBox.shrink(),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: Obx(
      () => controller.isLoadingSave.value
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF15A5A)),
            )
          : CustomButton(
              text: "SAVE EXPENSE",
              onPressed: () =>
                  controller.saveExpense(), // استدعاء الدالة المحدثة
              color: const Color(0xFFF15A5A),
            ),
    ),
  );
}
