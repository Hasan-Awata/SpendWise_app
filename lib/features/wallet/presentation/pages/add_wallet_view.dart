// // تعليق: واجهة إضافة محفظة جديدة مع ربط المتغيرات المحدثة في الـ Controller وحالة التحميل
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddWalletView extends StatefulWidget {
  const AddWalletView({super.key});

  @override
  State<AddWalletView> createState() => _AddWalletViewState();
}

class _AddWalletViewState extends State<AddWalletView> {
  // استخدام Get.find للوصول للمتحكم المحقون عبر الـ Binding
  final controller = Get.find<WalletController>();

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

            // // تعليق: استخدام قائمة العملات المفلترة من الـ Controller
            SPDropdownButton(
              title: "العملة",
              hint: "اختر العملة",
              values: controller.filteredCurrencies,
              onSelected: (index, value) {
                controller.currencySearchController.text = value;
                controller.selectedCurrencyId.value = index;
              },
              textEditingController: controller.currencySearchController,
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

            // // تعليق: تغيير زر الحفظ ليظهر مؤشر تحميل عند معالجة الطلب
            Obx(
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
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.addNewWallet(),
                  child: controller.isLoading.value
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
            const SizedBox(height: 40),
          ],
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
