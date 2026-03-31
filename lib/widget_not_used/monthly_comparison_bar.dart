import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/* هذه الويدجت تمثل مقارنة الدخل بالمصاريف شهرياً 
   لتحقيق هدف الرقابة المالية في مشروع Spendwise. 
*/

class MonthlyComparisonBar extends StatelessWidget {
  const MonthlyComparisonBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5000, // حد أعلى افتراضي بناءً على ميزانية المستخدم
          barGroups: [
            // بيانات شهر يناير
            makeGroupData(0, 4000, 3200), // دخل 4000، صرف 3200
            // بيانات شهر فبراير
            makeGroupData(1, 4200, 3800),
            // بيانات شهر مارس (الحالي)
            makeGroupData(2, 4000, 4500), // حالة عجز (صرف أكثر من الدخل)
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Jan', 'Feb', 'Mar'];
                  return Text(titles[value.toInt()]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لإنشاء مجموعة الأعمدة (دخل ومصروف)
  BarChartGroupData makeGroupData(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: Colors.green,
          width: 15,
          borderRadius: BorderRadius.circular(0),
        ), // عمود الدخل
        BarChartRodData(
          toY: expense,
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(0),
          width: 15,
        ), // عمود المصاريف
      ],
    );
  }
}
