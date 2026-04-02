import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';

class CustomButton2 extends StatelessWidget {
  final void Function()? onPressed;
  final Color? color;
  final String text;
  const CustomButton2({
    super.key,
    this.onPressed,
    this.color = SpColor.accentBlue,
    this.text = "save",
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: SpColor.primaryDark,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
