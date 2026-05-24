import 'package:get/get.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/savings_goals/presentation/bindings/saving_goal_binding.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>((() => MainController()), fenix: true);

    SavingGoalBinding().dependencies();
  }
}
