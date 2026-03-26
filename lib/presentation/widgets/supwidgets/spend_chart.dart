import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/* هذه الويدجت تحقق متطلب "التحليل البصري" في مشروع Spendwise 
  باستخدام مكتبة fl_chart المحددة في المقترح.
*/

class SpendChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 5,
          centerSpaceRadius: 40,
          sections: [
            // مثال لبيانات الفئات (يفضل جلبها من Provider)
            PieChartSectionData(
              color: Colors.orange,
              value: 40,
              title: 'طعام %40',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.blue,
              value: 30,
              title: 'سكن %30',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.purple,
              value: 30,
              title: 'أخرى %30',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
