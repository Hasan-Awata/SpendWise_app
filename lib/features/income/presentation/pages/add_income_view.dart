import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/widgets/tag_widget.dart';
import 'package:spendwise/features/income/presentation/manager/income_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field_description.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddIncomeView extends StatelessWidget {
  AddIncomeView({super.key});

  final controller = Get.find<IncomeController>();
  final RxBool isFixed = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildField(
                  "Amount",
                  controller.amountController,
                  Icons.monetization_on_outlined,
                ),
                const SizedBox(height: 30),
                _buildField(
                  "Source",
                  controller.sourceController,
                  Icons.source_outlined,
                ),
                const SizedBox(height: 25),
                _buildFixedToggle(),
                const SizedBox(height: 15),
                _buildRepetitionField(),
                const SizedBox(height: 25),
                CustomTextFieldDescription(
                  label: "Description",
                  hint: "Details...",
                  textEditingController: controller.descriptionController,
                  textColor: SpColor.incomeGreen,
                ),
                const SizedBox(height: 25),
                _buildDatePicker(context),
                const SizedBox(height: 30),
                const Divider(color: Colors.white10),
                const SizedBox(height: 30),
                _buildWalletDropdown(),
                const SizedBox(height: 25),
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
    );
  }

  // // --- Widgets ---

  PreferredSizeWidget _buildAppBar() => AppBar(
    title: const Text(
      "Add Income",
      style: TextStyle(color: SpColor.incomeGreen, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.transparent,
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: () => Get.toNamed('/income-list'),
        icon: Icon(Icons.all_inbox),
      ),
    ],
  );

  Widget _buildField(String label, TextEditingController ctr, IconData icon) =>
      CustomTextField(
        textColor: SpColor.incomeGreen,
        label: label,
        hint: "...",
        prefixIcon: Icon(icon, color: SpColor.incomeGreen),
        textEditingController: ctr,
      );

  Widget _buildFixedToggle() => Obx(
    () => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: SpColor.incomeGreen),
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(15),
        child: Material(
          borderRadius: BorderRadius.circular(15),
          color: Colors.transparent,
          child: SwitchListTile(
            title: const Text(
              "Fixed Income",
              style: TextStyle(color: Colors.white),
            ),
            activeColor: SpColor.incomeGreen,
            value: isFixed.value,
            onChanged: (v) => isFixed.value = v,
          ),
        ),
      ),
    ),
  );

  Widget _buildRepetitionField() => Obx(
    () => isFixed.value
        ? _buildField(
            "Repeat Every (Days)",
            controller.repeatController,
            Icons.calendar_month,
          )
        : const SizedBox.shrink(),
  );

  Widget _buildDatePicker(BuildContext context) => Obx(
    () => DatePickerWidget(
      onTap: () => controller.fetchDate(context),
      selectedDate: controller.selectedDate.value,
      color: SpColor.incomeGreen,
    ),
  );

  Widget _buildWalletDropdown() {
    return Obx(() {
      return SPDropdownButton(
        title: "Select Wallet",
        hint: "Choose wallet",
        textColor: SpColor.incomeGreen,
        prefixIcon: const Icon(Icons.wallet, color: SpColor.incomeGreen),
        values: controller.walletController.wallets
            .map((w) => w.currencyId.toString())
            .toList(),
        textEditingController: controller.walletTextController,
        // // تعليق: تم إلغاء onChanged والاعتماد على Listener في الكنترولر
        suffixIcon: IconButton(
          onPressed: () => Get.toNamed('/add-wallet'),
          icon: Icon(Icons.add),
        ),
      );
    });
  }

  Widget _buildTagDropdown() {
    return Obx(
      () => Column(
        children: [
          SPDropdownButton(
            title: "Select Tag",
            isTextField: true,
            hint: "Search/Type Tag",
            textColor: SpColor.incomeGreen,
            prefixIcon: const Icon(Icons.tag, color: SpColor.incomeGreen),
            values: controller.tagController.myTags.map((t) => t.name).toList(),
            textEditingController: controller.tagTextController,
            // // تعليق: تم إلغاء onChanged والاعتماد على Listener في الكنترولر
          ),
          if (controller.tagController.myTags.isEmpty)
            const Text(
              "✨ New tag will be created",
              style: TextStyle(color: SpColor.incomeGreen, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildTagPreview() => Obx(
    () => controller.selectedTag.value != null
        ? TagWidget(
            tagName: controller.selectedTag.value!.name,
            icon: Icons.check,
            color: SpColor.incomeGreen,
            onDelete: () => controller.tagTextController.clear(),
          )
        : const SizedBox.shrink(),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : CustomButton(
              text: "SAVE",
              onPressed: () {
                controller.saveIncome();
              },
              color: SpColor.incomeGreen,
            ),
    ),
  );
}
