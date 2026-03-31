import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// تعليق برمجي: حقل إدخال مخصص يفتح واجهة اختيار التاريخ لتحديد مواعيد الفواتير أو الأهداف.
class CustomDatePicker extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onDateSelected(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
