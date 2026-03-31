import 'package:flutter/material.dart';
import 'package:spendwise/utils/colors.dart';

class TitleWithShow extends StatelessWidget {
  final String title;
  final VoidCallback onMorePressed;
  TitleWithShow({super.key, required this.title, required this.onMorePressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: SpColor.offWhite,
          ),
        ),
        TextButton(
          onPressed: onMorePressed,
          child: const Text(
            "رؤية الكل",
            style: TextStyle(
              color: SpColor.accentBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
