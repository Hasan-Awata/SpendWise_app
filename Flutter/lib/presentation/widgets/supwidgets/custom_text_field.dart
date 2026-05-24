import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/presentation/auth/auth_controller.dart';
import 'package:spendwise/utils/colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final Widget prefixIcon;
  final bool isNumber; // هل الحقل للأرقام فقط؟
  final TextEditingController controller1;
  final String? Function(String?)? validator;
  final bool obscureText;

  CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller1,
    this.isNumber = false,
    this.validator,
    this.obscureText = false,
  });

  AuthController controller = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller1,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: validator,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: SpColor.accentBlue),
        hintText: hint, //نص تلميحي
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: prefixIcon, // لون متناسق مع BalanceCard
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
    );
  }
}
