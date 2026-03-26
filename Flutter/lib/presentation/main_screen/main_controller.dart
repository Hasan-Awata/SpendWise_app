import 'package:get/get.dart';

class MainController extends GetxController {
  static MainController get insatnce => Get.put(MainController());
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
