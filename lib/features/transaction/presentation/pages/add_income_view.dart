// presentation/views/add_income_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/transaction/presentation/manager/income_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddIncomeView extends StatelessWidget {
  AddIncomeView({super.key});

  final controller = Get.put(IncomeController()); // ربط الـ Controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1220), // Dark background من واجهاتك
      appBar: AppBar(
        title: Text(
          "إضافة دخل جديد",
          style: TextStyle(color: SpColor.incomeGreen),
        ),
        foregroundColor: SpColor.incomeGreen,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildAmountInput(), // حقل إدخال المبلغ
            const SizedBox(height: 30),
            _buildSourceDropdown(), // قائمة اختيار المصدر
            const SizedBox(height: 30),
            _buildDatePicker(context), // اختيار التاريخ
            const SizedBox(height: 50),
            _buildSubmitButton(), // زر الإضافة
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return CustomTextField(
      textColor: SpColor.incomeGreen,
      label: "المبلغ (SAR)",
      hint: "المبلغ (SAR)",
      prefixIcon: const Icon(Icons.money),
      textEditingController: TextEditingController(),
      isNumber: false,
      validator: (v) => v == null ? "المبلغ مطلوب" : null,
      onChanged: (v) => controller.incomeAmount.value = double.tryParse(v) ?? 0,
    );
  }

  Widget _buildSourceDropdown() {
    return SPDropdownButton(
      controller: controller,
      textColor: SpColor.incomeGreen,
      title: "source income",
      hint: 'Select or enter',
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return DatePickerWidget(controller: controller, color: SpColor.incomeGreen);
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: "save",
      onPressed: () {
        controller.saveIncome();
        if (!controller.values.contains(controller.selectedValue.value)) {
          controller.values.insert(0, controller.selectedValue.value);
        }
      },
      color: SpColor.incomeGreen,
    );
  }
}
