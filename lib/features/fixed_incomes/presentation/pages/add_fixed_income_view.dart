import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/fixed_incomes/presentation/manager/fixed_income_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddFixedIncomeView extends GetView<FixedIncomeController> {
  const AddFixedIncomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "دخل ثابت جديد", // تم التعديل للـ Income
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(Routes.LIST_FIXED_INCOME);
            },
            icon: Icon(Icons.list),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _sectionCard(
                children: [
                  _field(
                    "عنوان الدخل", // تم التعديل
                    controller.titleController,
                    Icons.title_rounded,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    "المبلغ (مثال: 5000.00)",
                    controller.amountController,
                    Icons.attach_money_rounded,
                    number: true,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    "يوم الاستحقاق (1-31)",
                    controller.daysController, // تم استخدام daysController
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 20),
                  _buildWalletDropdown(),
                  const SizedBox(height: 20),
                  _buildDatePicker(context),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 20),
                  _buildFixedIncomeSection(), // تم التعديل
                ],
              ),
              const SizedBox(height: 30),
              Obx(
                () => controller.isActionLoading.value
                    ? const CircularProgressIndicator(
                        color: Color.fromARGB(255, 0, 90, 84),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: CustomButton(
                          text: "حفظ الدخل", // تم التعديل
                          onPressed: () => controller.saveFixedIncome(),
                          color: SpColor.incomeGreen,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        prefixIcon: Icon(icon, color: SpColor.incomeGreen, size: 18),
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

  Widget _buildFixedIncomeSection() {
    return Obx(
      () => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: SpColor.surfaceNavy,
              borderRadius: BorderRadius.circular(20),
              gradient: controller.isActive.value
                  ? LinearGradient(
                      colors: [
                        SpColor.incomeGreen,
                        Colors.white.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border.all(
                color: controller.isActive.value
                    ? const Color.fromARGB(255, 0, 90, 84).withOpacity(0.5)
                    : Colors.white.withOpacity(0.05),
                width: 1.5,
              ),
            ),
            child: SwitchListTile(
              value: controller.isActive.value,
              onChanged: (v) => controller.isActive.value = v,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color.fromARGB(255, 0, 90, 84),
              inactiveThumbColor: Colors.white54,
              inactiveTrackColor: Colors.white10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: controller.isActive.value
                        ? const Color.fromARGB(255, 0, 90, 84)
                        : Colors.white54,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    " تفعيل الدخل الثابت", // تم التعديل
                    style: TextStyle(
                      color: controller.isActive.value
                          ? Colors.white
                          : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletDropdown() {
    return Obx(
      () => SPDropdownSearch(
        themeColor: SpColor.incomeGreen,

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

        hint: 'اختر محفظة',
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          "تاريخ آخر استحقاق",
          style: TextStyle(color: Colors.white70),
        ), // تم التعديل لـ LastTime
        trailing: Text(
          DateFormat('yyyy-MM-dd').format(controller.lastTime.value),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => controller.pickDate(context),
      ),
    );
  }
}
