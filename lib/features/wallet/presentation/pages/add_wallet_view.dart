import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';

// // تعليق: واجهة إضافة محفظة جديدة مع حقول إدخال مطابقة لتصميم الـ SignUp في التطبيق
class AddWalletView extends StatefulWidget {
  const AddWalletView({super.key});

  @override
  State<AddWalletView> createState() => _AddWalletViewState();
}

class _AddWalletViewState extends State<AddWalletView> {
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final controller = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B121E),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            _buildTextField(
              hint: 'اسم المحفظة',
              icon: Icons.edit,
              controller: nameController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              hint: 'الرصيد الابتدائي',
              icon: Icons.attach_money,
              controller: balanceController,
              isNumber: true,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43C5F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // // تعليق: إنشاء موديل جديد واستدعاء الكنترولر لحفظ البيانات في Hive والعودة للواجهة السابقة
                  final newWallet = WalletModel(
                    balance: double.tryParse(balanceController.text) ?? 0.0,
                    currencyId: 0,
                  );
                  controller.wallet.value = newWallet;
                  controller.addNewWallet();
                },
                child: const Text(
                  'حفظ المحفظة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
