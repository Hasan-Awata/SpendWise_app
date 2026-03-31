import 'package:flutter/material.dart';

/* هذه الويدجت تمثل الصندوق المخصص لرفع الصور واستخدام ميزة الـ OCR 
  الموجودة في متطلبات مشروع Spendwise (صفحة 15).
*/

class OCRUploadBox extends StatelessWidget {
  final VoidCallback onTap; // الدالة التي ستفتح الكاميرا أو الاستوديو

  const OCRUploadBox({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            style: BorderStyle.solid, // حدود منقطة تعطي إيحاء بالرفع
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.document_scanner_outlined,
              size: 50,
              color: Colors.blue,
            ),
            const SizedBox(height: 10),
            Text(
              "مسح الفاتورة ضوئياً (OCR)",
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              "ارفع صورة الفاتورة لاستخراج البيانات آلياً",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
