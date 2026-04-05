import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_controller.dart';
import 'package:spendwise/features/tags/presentation/pages/add_tag_page.dart';
import 'package:spendwise/features/tags/presentation/widgets/tag_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final controller = Get.put(ExpenseController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: AppBar(
        title: const Text(
          'New expense',
          style: TextStyle(
            color: SpColor.expenseRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: SpColor.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: SpColor.expenseRed),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            _buildAmountInput(controller),
            const SizedBox(height: 30),
            _buildSourceExpenseDropdown(controller),
            const SizedBox(height: 30),
            _buildTagDropdown(controller),
            const SizedBox(height: 20),
            _buildTagsToExpense(),

            const SizedBox(height: 50),
            _buildDatePicker(context),
            const SizedBox(height: 50),
            _buildSubmitButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsToExpense() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 10,
          children: List.generate(
            5,
            (index) => TagWidget(
              tagName: "tagName",
              icon: Icons.food_bank,
              color: SpColor.expenseRed,
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(ExpenseController controller) {
    return CustomTextField(
      textColor: SpColor.expenseRed.withAlpha(190),
      label: "المبلغ (SAR)",
      hint: "المبلغ (SAR)",
      prefixIcon: const Icon(Icons.money),
      textEditingController: TextEditingController(),
      isNumber: false,
      validator: (v) => v == null ? "المبلغ مطلوب" : null,
      onChanged: (v) =>
          controller.expenseAmount.value = double.tryParse(v) ?? 0,
    );
  }

  Widget _buildSourceExpenseDropdown(ExpenseController controller) {
    return SPDropdownButton(
      controller: controller,
      title: "source expense",
      hint: 'Select or enter',
      textColor: SpColor.expenseRed,
    );
  }

  Widget _buildTagDropdown(ExpenseController controller) {
    return SPDropdownButton(
      controller: controller,
      title: "tag",
      hint: "tag",
      textColor: SpColor.expenseRed.withAlpha(200),
      prefixIcon: const Icon(Icons.tag),
      suffixIcon: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          Get.to(() => const AddtagPage());
        },
        autofocus: true,
        highlightColor: SpColor.expenseRed.withAlpha(60),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return DatePickerWidget(
      controller: controller,
      color: SpColor.expenseRed.withAlpha(190),
    );
  }

  Widget _buildSubmitButton(ExpenseController controller) {
    return CustomButton(
      text: 'Save expense',
      onPressed: () => controller.saveExpense(),
      color: SpColor.expenseRed.withAlpha(190),
    );
  }
}
