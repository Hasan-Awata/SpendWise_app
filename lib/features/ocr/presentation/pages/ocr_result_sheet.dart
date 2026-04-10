import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/ocr/presentation/manager/ocr_controller.dart';

class OcrResultSheet extends GetView<OcrController> {
  const OcrResultSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // خلفية داكنة تناسب SpendWise
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
          );
        }

        final data = controller.scannedData.value;
        if (data == null) return const SizedBox();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط السحب العلوي
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "تأكيد بيانات الفاتورة",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // حقل المبلغ (Amount) - لون أخضر كما في تطبيقك
            _buildInputField(
              label: "المبلغ المستخرج",
              controller: TextEditingController(
                text: data.amount.toStringAsFixed(2),
              ),
              icon: Icons.attach_money,
              textColor: const Color(0xFF4ADE80),
            ),

            const SizedBox(height: 15),

            // حقل الوصف (Description)
            _buildInputField(
              label: "الوصف / المتجر",
              controller: TextEditingController(text: data.title),
              icon: Icons.store,
              textColor: Colors.white,
            ),

            const SizedBox(height: 15),

            // حقل التاريخ (Date)
            _buildInputField(
              label: "التاريخ",
              controller: TextEditingController(text: data.date),
              icon: Icons.calendar_today,
              textColor: Colors.white,
            ),

            const SizedBox(height: 30),

            // زر الحفظ النهائي
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //  controller.saveInvoiceToDatabase()
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "حفظ في العمليات",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // أداة بناء حقول الإدخال بتصميم متناسق
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color textColor,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
