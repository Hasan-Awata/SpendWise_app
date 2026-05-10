import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/wallet/presentation/manager/add_wallet_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddWalletView extends GetView<AddWalletController> {
  const AddWalletView({super.key});

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
            "إضافة محفظة",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),

          actions: [
            IconButton(
              onPressed: () => Get.toNamed('/list-wallet'),
              icon: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
              ),
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
                    _buildWalletHeader(),

                    const SizedBox(height: 24),

                    _buildCurrencyDropdown(),

                    const SizedBox(height: 18),

                    _modernField(
                      label: "الرصيد الابتدائي",
                      controller: controller.balanceController,
                      icon: Icons.attach_money_rounded,
                      number: true,
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                _buildSaveButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // SECTION CARD
  // =========================

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

  // =========================
  // HEADER
  // =========================

  Widget _buildWalletHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            gradient: LinearGradient(
              colors: [SpColor.mutedGrey, SpColor.mutedGrey.withOpacity(0.7)],
            ),

            boxShadow: [
              BoxShadow(
                color: SpColor.mutedGrey.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          "إنشاء محفظة جديدة",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "قم بإضافة محفظة لإدارة أموالك بسهولة",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  // =========================
  // MODERN FIELD
  // =========================

  Widget _modernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool number = false,
  }) {
    return TextField(
      controller: controller,

      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,

      style: const TextStyle(color: Colors.white, fontSize: 15),

      decoration: InputDecoration(
        labelText: label,

        labelStyle: const TextStyle(color: Colors.white60),

        prefixIcon: Container(
          margin: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color: SpColor.mutedGrey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),

          child: Icon(icon, color: SpColor.mutedGrey),
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

  // =========================
  // DROPDOWN
  // =========================

  Widget _buildCurrencyDropdown() {
    return SPDropdownSearch(
      themeColor: SpColor.mutedGrey,

      label: "العملة",

      hint: "اختر العملة",

      items: controller.allCurrencies.map((e) => e.currencyName ?? "").toList(),

      selectedItem: controller.currencySearchController.text.isNotEmpty
          ? controller.currencySearchController.text
          : null,

      onChanged: (value) {
        if (value == null) return;

        controller.currencySearchController.text = value;

        final currency = controller.allCurrencies.firstWhereOrNull(
          (e) => e.currencyName == value,
        );

        if (currency == null) return;

        controller.selectedCurrency.value = currency;
        controller.selectedCurrencyId.value = currency.id;
      },
    );
  }

  // =========================
  // SAVE BUTTON
  // =========================

  Widget _buildSaveButton() {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),

        child: controller.isLoadingSave.value
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(color: SpColor.mutedGrey),
              )
            : SizedBox(
                width: double.infinity,
                height: 58,

                child: CustomButton(
                  text: "حفظ المحفظة",

                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();

                    await controller.addNewWallet();
                  },

                  color: SpColor.mutedGrey,
                ),
              ),
      ),
    );
  }
}
