import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:spendwise/core/utils/colors.dart';

class DatePickerWidget extends StatelessWidget {
  final dynamic controller;
  final Color color;
  final String title;
  const DatePickerWidget({
    super.key,
    required this.controller,
    this.color = SpColor.accentBlue,
    this.title = "Date",
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: color),
        ),
        title: Text(title, style: TextStyle(color: SpColor.mutedGrey)),
        subtitle: Text(
          '${controller.selectedDate.value.year}-${controller.selectedDate.value.month.toString().padLeft(2, '0')}-${controller.selectedDate.value.day.toString().padLeft(2, '0')}',
          style: const TextStyle(color: SpColor.offWhite, fontSize: 15),
        ),
        trailing: Icon(Icons.calendar_today, color: color),
        onTap: () => controller.fetchDate(context),
      ),
    );
  }
}
