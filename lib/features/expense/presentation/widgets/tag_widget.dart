import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';

class TagWidget extends StatelessWidget {
  final String tagName;
  final IconData icon;
  final Color color;
  final VoidCallback? onDelete; // اختياري للحذف

  const TagWidget({
    super.key,
    required this.tagName,
    required this.icon,
    required this.color,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      // تصميم الحاوية
      backgroundColor: SpColor.surfaceNavy,

      side: BorderSide(color: color.withOpacity(0.4), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

      // المحتوى الداخلي
      avatar: Icon(icon, size: 30, color: color),
      label: Text(
        tagName,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      // التحكم في زر الحذف
      onDeleted: onDelete,
      deleteIcon: onDelete != null ? Icon(Icons.cancel, color: color) : null,

      // تنسيق المسافات
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
