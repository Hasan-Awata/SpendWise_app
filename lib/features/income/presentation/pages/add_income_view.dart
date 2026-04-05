// presentation/views/add_income_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/income/presentation/manager/income_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field_description.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddIncomeView extends StatelessWidget {
  AddIncomeView({super.key});

  final controller = Get.find<IncomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: AppBar(
        title: const Text(
          "Add New Income",
          style: TextStyle(
            color: SpColor.incomeGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed('/income-list');
            },
            icon: Icon(Icons.list, color: SpColor.incomeGreen),
          ),
        ],

        foregroundColor: SpColor.incomeGreen,
        backgroundColor: SpColor.primaryDark2,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // // UI: Amount Input with Currency Toggle
              _buildAmountInput(),
              const SizedBox(height: 30),

              // // UI Section: Main Income Type (isFixed)
              _buildFixedTypeSelector(),

              // // UI Logic: Conditional Recurrence Options
              Obx(
                () => AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: controller.isFixed.value
                      ? Column(
                          children: [
                            const SizedBox(height: 25),
                            _buildMonthlyToggle(),
                            // // UI Logic: Show Days input only if NOT monthly
                            if (!controller.isMonthly.value) ...[
                              const SizedBox(height: 20),
                              _buildDaysInput(),
                            ],
                          ],
                        )
                      : const SizedBox(height: 0, width: double.infinity),
                ),
              ),

              const SizedBox(height: 30),
              _buildSourceDropdown(),
              const SizedBox(height: 30),
              _buildDescriptionWidget(),
              const SizedBox(height: 30),
              _buildDatePicker(context),
              const SizedBox(height: 50),
              _buildSubmitButton(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // // UI Component: Selector for isFixed (Boolean)
  Widget _buildFixedTypeSelector() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Income Nature",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _typeCard(
                  label: "Fixed / Recurring",
                  isActive: controller.isFixed.value == true,
                  onTap: () => controller.isFixed.value = true,
                  icon: Icons.repeat_on_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _typeCard(
                  label: "One-Time",
                  isActive: controller.isFixed.value == false,
                  onTap: () {
                    controller.isFixed.value = false;
                    controller.isMonthly.value =
                        false; // // Logic: Reset when not fixed
                  },
                  icon: Icons.bolt_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // // UI Component: Toggle for isMonthly (Boolean)
  Widget _buildMonthlyToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        child: Obx(
          () => SwitchListTile(
            title: const Text(
              "Regular Monthly Income",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            subtitle: Text(
              controller.isMonthly.value
                  ? "Automatically recorded every month"
                  : "Custom recurrence by days",
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            value: controller.isMonthly.value,
            activeThumbColor: SpColor.incomeGreen,
            onChanged: (val) => controller.isMonthly.value = val,
          ),
        ),
      ),
    );
  }

  // // UI Component: Input for custom days (Days)
  Widget _buildDaysInput() {
    return CustomTextField(
      textColor: SpColor.incomeGreen,
      label: "Recurrence Period (Days)",
      hint: "e.g., 7 days or 15 days",
      prefixIcon: const Icon(
        Icons.calendar_today_rounded,
        color: SpColor.incomeGreen,
        size: 20,
      ),
      isNumber: true,
      onChanged: (v) => controller.days.value = int.tryParse(v) ?? 0,
      textEditingController: TextEditingController(),
    );
  }

  // // UI Helper: Generic Selection Card
  Widget _typeCard({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isActive
              ? SpColor.incomeGreen.withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? SpColor.incomeGreen : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? SpColor.incomeGreen : Colors.white38,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white38,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // // UI Component: Amount & Currency Toggle
  Widget _buildAmountInput() {
    return Obx(
      () => CustomTextField(
        textColor: SpColor.incomeGreen,
        label: controller.isUSdollar.value ? "Amount (USD)" : "Amount (SYP)",
        hint: "0.00",
        prefixIcon: SizedBox(
          width: 35,
          child: controller.isUSdollar.value
              ? const Icon(
                  Icons.attach_money_rounded,
                  color: SpColor.incomeGreen,
                )
              : const Center(
                  child: Text(
                    "SYP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: SpColor.incomeGreen,
                      fontSize: 12,
                    ),
                  ),
                ),
        ),
        textEditingController: TextEditingController(),
        isNumber: true,
        onChanged: (v) =>
            controller.incomeAmount.value = double.tryParse(v) ?? 0,
        suffixIcon: IconButton(
          onPressed: () => controller.isUSdollar.toggle(),
          icon: const Icon(
            Icons.currency_exchange,
            color: Colors.white54,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceDropdown() {
    return SPDropdownButton(
      controller: controller,
      textColor: SpColor.incomeGreen,
      title: "Income Source",
      hint: 'Select Source',
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return DatePickerWidget(
      controller: controller,
      color: SpColor.incomeGreen,
      title: "Date income",
    );
  }

  Widget _buildDescriptionWidget() {
    return CustomTextFieldDescription(
      label: "Description",
      hint: "Add extra details about this income...",
      textEditingController: controller.descriptionController,
      maxLines: 5, // // UI: Allows the field to grow up to 5 lines
      minLines: 3, // // UI: Starts with a height of 3 lines
      keyboardType: TextInputType
          .multiline, // // Logic: Enables 'Enter' key for new lines
      textColor: SpColor.incomeGreen,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: SpColor.incomeGreen),
              )
            : CustomButton(
                text: "Save Income",
                onPressed: () => controller.saveIncome(),
                color: SpColor.incomeGreen,
              ),
      ),
    );
  }
}
