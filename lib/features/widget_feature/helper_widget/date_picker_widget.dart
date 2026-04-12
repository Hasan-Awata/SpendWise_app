import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:spendwise/core/utils/colors.dart';

class DatePickerWidget extends StatelessWidget {
  final Color color;
  final String title;
  final void Function()? onTap;
  final DateTime selectedDate;
  const DatePickerWidget({
    super.key,

    this.color = SpColor.accentBlue,
    this.title = "Date",
    required this.onTap,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: color), // هنا نضع الحدود
      ),
      title: Text(title, style: TextStyle(color: SpColor.mutedGrey)),
      subtitle: Text(
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
        style: const TextStyle(color: SpColor.offWhite, fontSize: 15),
      ),
      trailing: Icon(Icons.calendar_today, color: color),
      onTap: onTap,
    );
  }
}
