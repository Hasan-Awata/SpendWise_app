import 'package:flutter/material.dart';

// تعليق برمجي: ويدجت تعرض رسالة توضيحية للمستخدم في حال كانت القوائم فارغة لتحسين تجربة المستخدم.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(subTitle, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
