/* هذه الويدجت تعرض التقدم نحو هدف ادخاري محدد 
   لتحقيق ميزة "تحسين كفاءة عمليات الادخار". 
*/
import 'package:flutter/material.dart';

class SavingsGoalCard extends StatelessWidget {
  final String goalName;
  final double currentSaved;
  final double targetAmount;

  const SavingsGoalCard({
    required this.goalName,
    required this.currentSaved,
    required this.targetAmount,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (currentSaved / targetAmount).clamp(0.0, 1.0);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              goalName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            Text(
              "وفرت \$${currentSaved.toStringAsFixed(0)} من أصل \$${targetAmount.toStringAsFixed(0)}",
            ),
          ],
        ),
      ),
    );
  }
}
