import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingLineChart extends StatelessWidget {
  const SpendingLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false), // إخفاء الشبكة لتبسيط الواجهة
          titlesData: FlTitlesData(
            show: true,
          ), // إظهار العناوين (الأيام والمبالغ)
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 50), // السبت: 50 ليرة
                const FlSpot(1, 80), // الأحد: 80 ليرة
                const FlSpot(2, 40), // الاثنين: 40 ليرة
                const FlSpot(3, 120), // الثلاثاء: قمة الإنفاق 120 ليرة
                const FlSpot(4, 90), // الأربعاء
                const FlSpot(5, 70), // الخميس
                const FlSpot(6, 60), // الجمعة
              ],
              isCurved: true, // جعل الخط منحنياً ليعطي مظهراً عصرياً
              color: const Color(0xFF6A11CB), // لون متناسق مع هوية التطبيق
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true), // إظهار نقاط عند كل يوم
              belowBarData: BarAreaData(
                show: true,
                color: const Color(
                  0xFF6A11CB,
                ).withOpacity(0.1), // تظليل تحت الخط
              ),
            ),
          ],
        ),
      ),
    );
  }
}
