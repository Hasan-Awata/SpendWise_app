import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

class TagController extends GetxController {
  static TagController get instance => Get.put(TagController());
  var tags = <TagModel>[
    TagModel(id: 1, ownerId: 2, label: "Food", categoryId: 1),
    TagModel(id: 1, ownerId: 2, label: "Health", categoryId: 1),
  ].obs;

  final Map<String, int> values = {
    "Basics": 1,
    "Secondaries": 2,
    "Expenses": 3,
    "Savings": 4,
  }.obs;
  RxString selectedValue = "Basic".obs;

  /// Persists to the in-app tag store (observable list).
  void addtag(TagModel newtag) {
    tags.insert(0, newtag);
    Get.snackbar(
      "Success",
      "tag saved",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.2),
      colorText: Colors.white,
    );
  }
}
