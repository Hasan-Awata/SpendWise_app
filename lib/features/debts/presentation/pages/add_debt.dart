import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/debts/presentation/manager/add_debt_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddSharedDebtView extends StatefulWidget {
  const AddSharedDebtView({super.key});

  @override
  State<AddSharedDebtView> createState() => _AddSharedDebtViewState();
}

class _AddSharedDebtViewState extends State<AddSharedDebtView> {
  final controller = Get.find<AddDebtController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: SpColor.accentBlue,
        title: const Text("إضافة دين"),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(Routes.SHARED_DEBTS);
            },
            icon: Icon(Icons.list),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card([
              _field("عنوان الدين", controller.titleController, Icons.title),
              const SizedBox(height: 15),
              _field(
                "المبلغ",
                controller.amountController,
                Icons.attach_money,
                number: true,
              ),
              const SizedBox(height: 15),
              _field(
                "اسم المستخدم",
                controller.userNameController,
                Icons.person,
              ),
            ]),

            const SizedBox(height: 18),

            // ===== ROLE SELECT =====
            _card([
              Obx(
                () => Column(
                  children: [
                    RadioListTile(
                      title: const Text(
                        "أنا دائن",
                        style: TextStyle(color: SpColor.accentBlue),
                      ),
                      value: DebtRole.creditor,
                      activeColor: SpColor.accentBlue,
                      groupValue: controller.role.value,
                      onChanged: (v) => controller.role.value = v!,
                    ),
                    RadioListTile(
                      title: const Text(
                        "أنا مدين",
                        style: TextStyle(color: SpColor.accentBlue),
                      ),
                      value: DebtRole.debtor,
                      activeColor: SpColor.accentBlue,
                      groupValue: controller.role.value,
                      onChanged: (v) => controller.role.value = v!,
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 18),

            _card([
              Obx(
                () => DatePickerWidget(
                  selectedDate: controller.dueDate.value,
                  onTap: () => controller.selectDueDate(context),
                  color: SpColor.accentBlue,
                ),
              ),
            ]),

            const SizedBox(height: 18),

            _card([_buildWalletDropdown()]),

            const SizedBox(height: 25),

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 55,
                child: controller.isLoadingSave.value
                    ? Center(
                        child: const CircularProgressIndicator(
                          color: SpColor.accentBlue,
                        ),
                      )
                    : CustomButton(
                        text: "حفظ الدين",
                        onPressed: controller.saveDebt,
                        color: SpColor.accentBlue,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletDropdown() {
    return Obx(() {
      final wallets = controller.walletsListController.regularWallets;

      return SPDropdownSearch(
        themeColor: SpColor.accentBlue,
        label: "المحفظة",
        hint: "اختر محفظة",
        items: wallets
            .map((w) => "${w.currency.currencyName} (${w.currency.code})")
            .toList(),
        onChanged: (value) {
          final wallet = wallets.firstWhere(
            (w) => "${w.currency.currencyName} (${w.currency.code})" == value,
          );

          controller.selectedWallet.value = wallet;
        },
      );
    });
  }

  Widget _card(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      ),
    ),
    child: Column(children: children),
  );

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
        prefixIcon: Icon(icon, color: SpColor.accentBlue, size: 18),
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
}
