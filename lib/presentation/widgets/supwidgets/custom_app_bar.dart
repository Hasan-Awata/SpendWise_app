import 'package:flutter/material.dart';
import 'package:spendwise/utils/colors.dart';

// تعليق برمجي: شريط علوي مخصص لتوحيد مظهر الصفحات في تطبيق SpendWise.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color background;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: SpColor.accentBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: background,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
