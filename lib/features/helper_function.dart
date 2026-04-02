import 'package:flutter/material.dart';

class HelperFunction {
  static Future<DateTime?>? chooseDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),

      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyan, // لون السيان من تصميمك
              onPrimary: Colors.white,
              surface: Color(0xFF1A1F2B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    return pickedDate!;
  }
}
