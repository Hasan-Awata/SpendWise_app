// // تعليق: واجهة إضافة محفظة جديدة مع ربط المتغيرات المحدثة في الـ Controller وحالة التحميل
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/wallet/presentation/manager/add_wallet_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddWalletView extends StatefulWidget {
  const AddWalletView({super.key});

  @override
  State<AddWalletView> createState() => _AddWalletViewState();
}

class _AddWalletViewState extends State<AddWalletView> {
  final controller = Get.find<AddWalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B121E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'إضافة محفظة جديدة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // // استبدال القائمة المنسدلة بالكلاس الجديد المعتمد على مكتبة البحث
            SPDropdownSearch(
              label: "العملة",
              hint: "اختر العملة",
              items: controller.filteredCurrencies,
              selectedItem: controller.currencySearchController.text.isNotEmpty
                  ? controller.currencySearchController.text
                  : null,
              onChanged: (value) {
                if (value != null) {
                  controller.currencySearchController.text = value;
                  // الحصول على الـ index الخاص بالعنصر المختار من القائمة
                  int index = controller.filteredCurrencies.indexOf(value);
                  controller.selectedCurrencyId.value = index;
                }
              },
            ),

            const SizedBox(height: 20),

            _buildTextField(
              hint: 'الرصيد الابتدائي',
              icon: Icons.attach_money,
              controller: controller
                  .balanceController, // تم تعديل الاسم ليتوافق مع الـ Controller الجديد
              isNumber: true,
            ),

            const SizedBox(height: 60),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveingButton(),
    );
  }

  Widget _buildSaveingButton() {
    return
    // // تعليق: تغيير زر الحفظ ليظهر مؤشر تحميل عند معالجة الطلب
    SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43C5F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async => await controller.addNewWallet(),
              child: controller.isLoadingSave.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'حفظ المحفظة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF162030),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
