import 'package:flutter/material.dart';
import 'package:spendwise/utils/colors.dart';

class BuildFinanceinfo extends StatelessWidget {
  final String title;
  final double amount;
  final IconData? icon;
  final Color colorIcon;
  final double fontSizeAmount;
  final Color colorText;
  final Color background;
  final double borderRadius;
  final Color shadowColor;
  final Color colorBorder;
  final double elevation;
  BuildFinanceinfo({
    super.key,
    required this.title,
    required this.amount,
    this.icon,
    required this.colorIcon,
    required this.colorText,
    required this.fontSizeAmount,
    required this.background,
    required this.borderRadius,
    required this.shadowColor,
    this.colorBorder = Colors.transparent,
    this.elevation = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      elevation: elevation,
      shadowColor: shadowColor,
      borderRadius: BorderRadius.circular(borderRadius),

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: colorBorder),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon != null
                  ? Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: SpColor.primaryDark,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: colorIcon, size: 20),
                    )
                  : const SizedBox(),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(color: colorText, fontSize: 14)),

                  Text(
                    "\$${amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: colorText,
                      fontSize: fontSizeAmount,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
