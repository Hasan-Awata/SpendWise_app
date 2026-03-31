import 'package:flutter/material.dart';
import 'package:spendwise/utils/colors.dart';

class SavingsGoalsSection extends StatelessWidget {
  const SavingsGoalsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "الأهداف الادخارية",
          style: TextStyle(
            color: SpColor.offWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildGoalCard("لاب توب جديد", 0.75, "SAR 3,000", Colors.orange),
              _buildGoalCard("رحلة صيفية", 0.40, "SAR 1,200", Colors.blue),
              _buildGoalCard("صندوق الطوارئ", 0.90, "SAR 5,000", Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(
    String title,
    double progress,
    String amount,
    Color color,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: SpColor.surfaceNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SpColor.offWhite,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
