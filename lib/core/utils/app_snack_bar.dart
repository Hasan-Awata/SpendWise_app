import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackBar {
  static void show(String title, String message, {bool isError = false}) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.red.withOpacity(0.9)
          : Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
    );
  }
}
