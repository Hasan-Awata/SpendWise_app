import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: SpColor.surfaceNavy,
        gradient: const LinearGradient(
          colors: [SpColor.surfaceNavy, SpColor.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: SpColor.accentBlue.withValues(alpha: 0.1, blue: 1.6),
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "إجمالي الرصيد",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "SAR 12,450.00",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFlowStat(
                Icons.arrow_downward,
                "الدخل",
                "SAR 5,200",
                SpColor.incomeGreen,
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildFlowStat(
                Icons.arrow_upward,
                "المصاريف",
                "SAR 1,150",
                SpColor.expenseRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStat(
    IconData icon,
    String label,
    String amount,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: SpColor.primaryDark,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: SpColor.offWhite,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
