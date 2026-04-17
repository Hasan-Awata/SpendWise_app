import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/widgets/tag_widget.dart';
import 'package:spendwise/features/income/presentation/manager/add_income_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
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
  final RxBool isFixed = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: SpColor.incomeGreen,
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
                  _buildField(
                    "Amount",
                    controller.amountController,
                    Icons.monetization_on_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildField(
                    "Source",
                    controller.sourceController,
                    Icons.source_outlined,
                  ),
                  const SizedBox(height: 25),
                  _buildFixedToggle(),
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
                  const Divider(color: Colors.white10, thickness: 1),
                  const SizedBox(height: 30),
                  _buildWalletDropdown(),
                  const SizedBox(height: 25),
                  _buildTagDropdown(),
                  _buildTagPreview(),
                  const SizedBox(height: 40),
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

  PreferredSizeWidget _buildAppBar() => AppBar(
    title: const Text(
      "Add Income",
      style: TextStyle(color: SpColor.incomeGreen, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: SpColor.incomeGreen,
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: () => Get.toNamed(Routes.LIST_INCOME),
        icon: const Icon(Icons.all_inbox_rounded),
      ),
    ],
  );

  Widget _buildField(
    String label,
    TextEditingController ctr,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) => CustomTextField(
    textColor: SpColor.incomeGreen,

    label: label,
    hint: "Enter $label",
    prefixIcon: Icon(icon, color: SpColor.incomeGreen),
    textEditingController: ctr,
  );

  Widget _buildFixedToggle() => Obx(
    () => Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: SpColor.incomeGreen.withOpacity(0.5)),
      ),
      child: SwitchListTile(
        title: const Text(
          "Fixed Income",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        activeColor: SpColor.incomeGreen,
        value: isFixed.value,
        onChanged: (v) => isFixed.value = v,
      ),
    ),
  );

  Widget _buildRepetitionField() => Obx(
    () => isFixed.value
        ? Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildField(
              "Repeat Every (Days)",
              controller.repeatController,
              Icons.calendar_month,
              keyboardType: TextInputType.number,
            ),
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
    return Obx(
      () => SPDropdownButton(
        title: "Select Wallet",
        hint: "Choose wallet",
        textColor: SpColor.incomeGreen,
        prefixIcon: const Icon(
          Icons.account_balance_wallet_outlined,
          color: SpColor.incomeGreen,
        ),
        values: controller.walletsListController.wallets
            .map(
              (w) =>
                  "${w.currency.currencyName} (${w.currency.code} ${w.balance})",
            )
            .toList(),
        textEditingController: controller.walletTextController,
        onSelected: (index, value) {
          controller.selectedWallet.value =
              controller.walletsListController.wallets[index];
          controller.walletTextController.text = value;
        },
        suffixIcon: IconButton(
          onPressed: () async {
            await Get.toNamed(Routes.ADD_WALLET);
          },
          icon: const Icon(
            Icons.add_circle_outline,
            color: SpColor.incomeGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildTagDropdown() {
    return Obx(() {
      bool isNewTag =
          controller.tagTextController.text.trim().isNotEmpty &&
          !controller.tagController.myTags.any(
            (t) =>
                t.name.toLowerCase() ==
                controller.tagTextController.text.trim().toLowerCase(),
          );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SPDropdownButton(
            title: "Select Tag",
            isTextField: true,
            hint: "Search or Type Tag",
            textColor: SpColor.incomeGreen,
            prefixIcon: const Icon(
              Icons.local_offer_outlined,
              color: SpColor.incomeGreen,
            ),
            values: controller.tagController.myTags.map((t) => t.name).toList(),
            textEditingController: controller.tagTextController,
            onSelected: (index, value) {
              controller.selectedTag.value =
                  controller.tagController.myTags[index];
              controller.tagTextController.text = value;
            },
          ),
          if (isNewTag)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 10.0),
              child: Text(
                "✨ Tag \"${controller.tagTextController.text}\" will be created.",
                style: const TextStyle(
                  color: SpColor.incomeGreen,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 10),
        ],
      );
    });
  }

  Widget _buildTagPreview() => Obx(
    () => controller.selectedTag.value != null
        ? Padding(
            padding: const EdgeInsets.only(top: 5),
            child: TagWidget(
              tagName: controller.selectedTag.value!.name,
              icon: Icons.tag,
              color: SpColor.incomeGreen,
              onDelete: () {
                controller.selectedTag.value = null;
                controller.tagTextController.clear();
              },
            ),
          )
        : const SizedBox.shrink(),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: Obx(
      () => controller.isLoadingSave.value
          ? const Center(
              child: CircularProgressIndicator(
                color: SpColor.incomeGreen,
                strokeWidth: 3,
              ),
            )
          : CustomButton(
              text: "SAVE INCOME",
              onPressed: () => controller.saveIncome(),
              color: SpColor.incomeGreen,
            ),
    ),
  );
}
