// // UI Component: Versatile CustomTextFieldDescription supporting multiline descriptions
import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';

class CustomTextFieldDescription extends StatefulWidget {
  final String label;
  final String hint;
  final Widget? prefixIcon;
  final bool isNumber;
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final void Function()? onTap;
  final Color textColor;
  final Widget? suffixIcon;

  // // Logic: Added parameters for multiline support
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;

  const CustomTextFieldDescription({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    required this.textEditingController,
    this.isNumber = false,
    this.validator,
    this.obscureText = false,
    this.onChanged,
    this.onTap,
    this.textColor = SpColor.accentBlue,
    this.suffixIcon,
    this.maxLines = 1, // // UI: Default to 1 line for standard inputs
    this.minLines,
    this.keyboardType,
  });

  @override
  State<CustomTextFieldDescription> createState() =>
      _CustomTextFieldDescriptionState();
}

class _CustomTextFieldDescriptionState
    extends State<CustomTextFieldDescription> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      // // Logic: Dynamic keyboard type based on isNumber or explicit keyboardType
      keyboardType:
          widget.keyboardType ??
          (widget.isNumber ? TextInputType.number : TextInputType.text),

      validator: widget.validator,
      obscureText: widget.obscureText,

      // // UI: Description support
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,

      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      onTap: widget.onTap,

      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: widget.textColor,
          fontWeight: FontWeight.bold,
        ),
        // // UI: Align label to top-left for multiline inputs
        alignLabelWithHint: (widget.maxLines ?? 1) > 1,

        hintText: widget.hint,
        hintStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
        suffixIcon: widget.suffixIcon,
        prefixIcon: widget.prefixIcon,
        filled: true,
        fillColor: SpColor.surfaceNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
