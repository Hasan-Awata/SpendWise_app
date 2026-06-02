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
        _buildActionItem(Icons.account_tree_outlined, "التقسيم", () {}),
        _buildActionItem(Icons.tag_outlined, "الفئات", () {}),
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
