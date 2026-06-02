import 'dart:io';

import 'package:get/get.dart';
import 'package:spendwise/core/network/network_service.dart';

class ReceiptApiService {
  final String _endpoint = "ocr"; // // استبدل هذا بعنوان الـ API الخاص بك

  final NetworkService _networkService = Get.find<NetworkService>();
  Future<Map<String, dynamic>?> uploadReceipt(File imageFile) async {
    try {
      var request = _networkService.upload(
        endpoint: _endpoint,
        file: imageFile,
      );
    } catch (e) {
      print("Exception: $e");
      return null;
    }
    return null;
  }
}
