import 'package:flutter/material.dart';

class SpColor {
  SpColor._();
  // static const Color darkTeal = Color(0xFF003B44);
  // static const Color teal = Color(0xFF0C6F73);
  // static const Color lightTeal = Color(0xFF39C0C3);
  // static const Color white = Color(0xFFFFFFFF);
  // static const Color lightGrey = Color(0xFFC9D1D3);
  // static const Color darkNavy = Color(0xFF1E1E2C);
  static const Color primaryDark = Color(
    0xFF0F172A,
  ); // كحلي عميق للخلفية (بديل darkTeal)
  static const Color surfaceNavy = Color(
    0xFF1E293B,
  ); // كحلي متوسط للبطاقات (بديل teal)
  static const Color accentBlue = Color(
    0xFF38BDF8,
  ); // أزرق سماوي للتحديد (بديل lightTeal)
  static const Color offWhite = Color(
    0xFFF8FAFC,
  ); // أبيض مريح للعين (بديل white الصارخ)
  static const Color mutedGrey = Color(
    0xFF94A3B8,
  ); // رمادي للنصوص الثانوية (بديل lightGrey)
  static const Color cardShadow = Color(
    0xFF020617,
  ); // لون ظل داكن جداً (بديل darkNavy)

  // ألوان مضافة للعمليات المالية (ضرورية للتطبيق)
  static const Color incomeGreen = Color(0xFF10B981); // أخضر للراتب والدخل
  static const Color expenseRed = Color(0xFFEF4444);

  static const Color savinggoalColor = Color.fromARGB(
    255,
    250,
    173,
    91,
  ); // أزرق لأهداف الادخار
  static const Color tagColor = Colors.deepPurpleAccent;
  static const Color primaryDark2 = Color(0xFF0B1220);
}
