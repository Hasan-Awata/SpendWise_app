import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.put(AuthController());

  var visibility = false.obs;
}
