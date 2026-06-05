import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendwise/core/utils/colors.dart';

class HelperFunction {
  static Future<DateTime?> chooseDate(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
    return pickedDate;
  }

  // [Comment: إضافة دالة حوار تأكيدي لاستخدامها في التحقق من الميزانية]
  static Future<bool> showConfirmationDialog(
    String title,
    String message,
  ) async {
    bool confirmed = false;

    await Get.defaultDialog(
      backgroundColor: SpColor.surfaceNavy,
      middleTextStyle: TextStyle(color: SpColor.offWhite),
      titleStyle: TextStyle(color: SpColor.offWhite),
      title: title,
      middleText: message,
      textConfirm: "متابعة",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      onConfirm: () {
        confirmed = true;
        Get.back();
      },
      onCancel: () {
        confirmed = false;
      },
    );

    return confirmed;
  }

  static String? validatePassword(String? value) {
    // 1. التحقق من أن الحقل ليس فارغاً
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // 2. التحقق من الحد الأدنى للطول (مثلاً 8 محارف)
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // 3. التحقق من وجود حرف كبير واحد على الأقل (Uppercase)
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // 4. التحقق من وجود حرف صغير واحد على الأقل (Lowercase)
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // 5. التحقق من وجود رقم واحد على الأقل (Digit)
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // 6. التحقق من وجود رمز خاص واحد على الأقل (Special Character)
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character (!@#\$%^&*)';
    }

    // إذا اجتازت كل الاختبارات
    return null;
  }

  static void showSnackBar(
    String title,
    String message, {
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.35)
          : SpColor.incomeGreen.withOpacity(0.5),
      colorText: SpColor.offWhite,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(15),
      borderRadius: 10,
    );
  }

  static int fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit;
      hash *= 0x100000001b3;
    }
    return hash;
  }

  static Widget buildShimmer({double height = 56, double radius = 20}) {
    return Shimmer.fromColors(
      baseColor: SpColor.surfaceNavy.withOpacity(0.3),
      highlightColor: SpColor.surfaceNavy.withOpacity(0.6),
      child: ClipRRect(
        // إضافة هذا لقص الحواف
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
