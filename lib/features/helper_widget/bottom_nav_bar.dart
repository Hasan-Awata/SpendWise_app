import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/presentation/main_screen/main_controller.dart';
import 'package:spendwise/utils/colors.dart';

class SPBottomNavBar extends StatelessWidget {
  SPBottomNavBar({super.key});
  MainController controller = MainController.insatnce;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),

      notchMargin: 10,
      color: SpColor.surfaceNavy,
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.grid_view_rounded,
                      color: controller.currentIndex.value == 0
                          ? SpColor.accentBlue
                          : SpColor.mutedGrey,
                    ),
                    onPressed: () {
                      controller.changePage(0);
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      Icons.bar_chart_outlined,
                      color: controller.currentIndex.value == 1
                          ? SpColor.accentBlue
                          : SpColor.mutedGrey,
                    ),
                    onPressed: () {
                      controller.changePage(1);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: controller.currentIndex.value == 2
                          ? SpColor.accentBlue
                          : SpColor.mutedGrey,
                    ),
                    onPressed: () {
                      controller.changePage(2);
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: controller.currentIndex.value == 3
                          ? SpColor.accentBlue
                          : SpColor.mutedGrey,
                    ),
                    onPressed: () {
                      controller.changePage(3);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
