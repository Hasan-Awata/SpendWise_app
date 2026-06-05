import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/ocr/receiptScannerScreen.dart'
    show ReceiptScannerScreen;

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(Icons.document_scanner_outlined, "مسح (OCR)", () {
          Get.to(() => ReceiptScannerScreen());
        }),
        _buildActionItem(Icons.qr_code_2_outlined, "رمز QR", () {}),
        _buildActionItem(Icons.account_tree_outlined, "التقسيم", () {
          Get.to(SplitBillView());
        }),
        _buildActionItem(Icons.tag_outlined, "الفئات", () {
          Get.to(CategoriesView());
        }),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: SpColor.surfaceNavy,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: SpColor.accentBlue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: SpColor.accentBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryModel {
  final String name;
  final int priority;
  CategoryModel({required this.name, required this.priority});
}

class CategoriesView extends StatelessWidget {
  CategoriesView({super.key});

  // قائمة الفئات مباشرة هنا
  final List<CategoryModel> categories = [
    CategoryModel(name: "Essentials", priority: 1),
    CategoryModel(name: "Secondaries", priority: 2),
    CategoryModel(name: "Luxuries", priority: 3),
    CategoryModel(name: "Savings", priority: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        title: const Text("الفئات", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3, // تعديل النسبة لتعطي مساحة أكبر للنص
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            decoration: BoxDecoration(
              color: SpColor.surfaceNavy,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: SpColor.accentBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  color: SpColor.accentBlue,
                  size: 35,
                ),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "الأولوية: ${category.priority}",
                  style: TextStyle(
                    color: SpColor.accentBlue.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SplitBillView extends StatelessWidget {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController peopleController = TextEditingController();

  SplitBillView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        title: const Text("تقسيم الفاتورة"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInputField(
              amountController,
              "إجمالي المبلغ",
              Icons.attach_money,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              peopleController,
              "عدد الأشخاص",
              Icons.people_outline,
            ),
            const SizedBox(height: 30),

            // زر الحساب
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SpColor.accentBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0;
                int people = int.tryParse(peopleController.text) ?? 1;
                double result = amount / people;

                Get.defaultDialog(
                  title: "نتيجة التقسيم",
                  backgroundColor: SpColor.surfaceNavy,
                  content: Text(
                    "نصيب الشخص الواحد: ${result.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              child: const Text(
                "احسب النصيب",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: SpColor.accentBlue),
        filled: true,
        fillColor: SpColor.surfaceNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
