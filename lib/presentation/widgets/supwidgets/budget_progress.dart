/* هذه الويدجت تحقق متطلب "إرسال تنبيهات بصرية عند تجاوز نسب الاستهلاك" 
  المذكور في مقترح مشروع Spendwise 
*/

import 'package:flutter/material.dart';

class BudgetProgressBar extends StatelessWidget {
  final String categoryName; // اسم الفئة (مثلاً: طعام)
  final double spentAmount; // المبلغ المصروف فعلياً
  final double totalBudget; // السقف المحدد لهذه الفئة

  const BudgetProgressBar({
    super.key,
    required this.categoryName,
    required this.spentAmount,
    required this.totalBudget,
  });

  @override
  Widget build(BuildContext context) {
    // حساب نسبة الاستهلاك (من 0.0 إلى 1.0)
    double progress = (spentAmount / totalBudget).clamp(0.0, 1.0);

    // تحديد اللون بناءً على النسبة
    Color progressColor;
    if (progress < 0.5) {
      progressColor = Colors.green; // آمن
    } else if (progress < 0.85) {
      progressColor = Colors.orange; // انتبه
    } else {
      progressColor = Colors.red; // خطير (اقترب من السقف)
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${(progress * 100).toInt()}%"),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "متبقي لك: \$${(totalBudget - spentAmount).toStringAsFixed(2)}",
          style: TextStyle(fontSize: 12, color: progressColor),
        ),
      ],
    );
  }
}
