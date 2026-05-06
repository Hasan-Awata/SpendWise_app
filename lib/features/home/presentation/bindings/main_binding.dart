import 'package:get/get.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>((() => MainController()), fenix: true);
  }
}
