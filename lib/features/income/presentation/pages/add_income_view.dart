// add_income_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/income/presentation/manager/add_income_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field_description.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddIncomeView extends StatefulWidget {
  const AddIncomeView({super.key});

  @override
  State<AddIncomeView> createState() => _AddIncomeViewState();
}

class _AddIncomeViewState extends State<AddIncomeView> {
  final controller = Get.find<AddIncomeController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),

      child: Scaffold(
        backgroundColor: const Color(0xFF020817),

        appBar: AppBar(
          elevation: 0,
          foregroundColor: SpColor.incomeGreen,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.list, color: Colors.white70),

              onPressed: () => Get.toNamed(Routes.LIST_INCOME),
            ),
          ],
          centerTitle: true,

          title: const Text(
            "دخل جديد",

            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            child: Column(
              children: [
                const SizedBox(height: 20),

                // =====================
                // BASIC INFO
                // =====================
                _card([
                  _field(
                    "عنوان الدخل",
                    controller.sourceController,
                    Icons.title_rounded,
                  ),

                  const SizedBox(height: 15),

                  _field(
                    "المبلغ",
                    controller.amountController,
                    Icons.attach_money_rounded,
                    number: true,
                  ),
                ]),

                const SizedBox(height: 18),

                // =====================
                // DATE
                // =====================
                _card([
                  Obx(
                    () => DatePickerWidget(
                      onTap: () => controller.fetchDate(context),

                      selectedDate: controller.selectedDate.value,

                      color: SpColor.incomeGreen,
                    ),
                  ),
                ]),

                const SizedBox(height: 18),

                // =====================
                // WALLET
                // =====================
                _card([_buildWalletDropdown()]),

                const SizedBox(height: 18),

                // =====================
                // DESCRIPTION
                // =====================
                _card([
                  CustomTextFieldDescription(
                    label: "الوصف",

                    hint: "تفاصيل إضافية...",

                    textEditingController: controller.descriptionController,

                    textColor: SpColor.incomeGreen,
                  ),
                ]),

                const SizedBox(height: 18),

                // =====================
                // TAG
                // =====================
                _card([_buildTagDropdown()]),

                const SizedBox(height: 30),

                // =====================
                // SAVE BUTTON
                // =====================
                _buildSubmitButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // CARD
  // =========================

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),

        border: Border.all(color: Colors.white12),
      ),

      child: Column(children: children),
    );
  }

  // =========================
  // FIELD
  // =========================

  Widget _field(
    String label,
    TextEditingController ctr,
    IconData icon, {
    bool number = false,
  }) {
    return TextField(
      controller: ctr,

      keyboardType: number ? TextInputType.number : TextInputType.text,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon, color: SpColor.incomeGreen),

        labelStyle: const TextStyle(color: Colors.white70),

        filled: true,

        fillColor: Colors.white.withOpacity(0.04),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // =========================
  // WALLET
  // =========================

  Widget _buildWalletDropdown() {
    return Obx(
      () => SPDropdownSearch(
        themeColor: SpColor.incomeGreen,

        label: "المحفظة",

        items: controller.walletsListController.wallets
            .map((w) => "${w.currency.currencyName} (${w.currency.code})")
            .toList(),

        onChanged: (value) {
          final index = controller.walletsListController.wallets.indexWhere(
            (w) =>
                "${w.currency.currencyName} (${w.currency.code})"
                    .toLowerCase()
                    .trim() ==
                value?.toLowerCase().trim(),
          );
          if (index != -1) {
            controller.selectedWallet.value =
                controller.walletsListController.wallets[index];
          }
        },

        hint: 'اختر محفظة',
      ),
    );
  }

  // =========================
  // TAGS
  // =========================

  Widget _buildTagDropdown() {
    return Obx(
      () => SPDropdownSearch(
        themeColor: SpColor.incomeGreen,

        label: "الوسم",

        items: controller.tagController.myTags.map((t) => t.name).toList(),

        onChanged: (v) {
          controller.tagTextController.text = v ?? "";
        },

        hint: 'اختر وسم',
      ),
    );
  }

  // =========================
  // BUTTON
  // =========================

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 55,

        child: controller.isLoadingSave.value
            ? const Center(
                child: CircularProgressIndicator(color: SpColor.incomeGreen),
              )
            : CustomButton(
                text: "حفظ الدخل",

                onPressed: () => controller.saveIncome(),

                color: SpColor.incomeGreen,
              ),
      ),
    );
  }
}
