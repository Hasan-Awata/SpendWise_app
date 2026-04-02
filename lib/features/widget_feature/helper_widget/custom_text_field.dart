import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/auth_controller.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final Widget? prefixIcon;
  final bool isNumber; // هل الحقل للأرقام فقط؟
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final void Function()? onTap;
  final Color textColor;
  final Widget? suffixIcon;
  const CustomTextField({
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
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  AuthController textEditingController = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      keyboardType: widget.isNumber ? TextInputType.number : TextInputType.text,
      validator: widget.validator,
      obscureText: widget.obscureText,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),

      onTap: widget.onTap,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: widget.textColor,
          fontWeight: FontWeight.bold,
        ),
        hintText: widget.hint, //نص تلميحي
        hintStyle: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
        suffixIcon: widget.suffixIcon,
        prefixIcon: widget.prefixIcon, // لون متناسق مع BalanceCard
        filled: true,
        fillColor: SpColor.surfaceNavy,

        border: OutlineInputBorder(
          //status normal
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          //status write
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
