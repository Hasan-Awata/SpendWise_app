import 'package:flutter/material.dart';

/* يحقق ميزة "إرسال تنبيهات عند تجاوز نسب الاستهلاك" (صفحة 14) */
class SmartNotificationTile extends StatelessWidget {
  final String message;
  final String type; // 'warning' or 'tip'

  const SmartNotificationTile({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: type == 'warning' ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: type == 'warning' ? Colors.red[200]! : Colors.blue[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            type == 'warning'
                ? Icons.warning_amber_rounded
                : Icons.lightbulb_outline,
            color: type == 'warning' ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
