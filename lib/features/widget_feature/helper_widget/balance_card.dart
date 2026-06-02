// lib/features/home/presentation/widgets/balance_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainController>();

    return GestureDetector(
      onTap: () => _showWalletPicker(context, mainController),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy,
          gradient: const LinearGradient(
            colors: [SpColor.surfaceNavy, SpColor.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: SpColor.accentBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Obx(() {
          final isLoading = mainController.isLoading.value;
          final activeWallet =
              mainController.selectWallet.value ??
              (mainController.walletListController.regularWallets.isNotEmpty
                  ? mainController.walletListController.regularWallets[0]
                  : null);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "إجمالي الرصيد الحقيقي",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      _buildWalletBadge(activeWallet, isLoading),
                    ],
                  ),
                  _buildMonthPicker(mainController, context),
                ],
              ),
              const SizedBox(height: 15),
              _buildBalanceDisplay(activeWallet, isLoading),
              const SizedBox(height: 20),
              _buildStatsRow(mainController, activeWallet, isLoading),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildWalletBadge(activeWallet, bool isLoading) {
    if (isLoading) return _buildShimmer(width: 80, height: 18, radius: 6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: SpColor.accentBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        activeWallet?.currency.currencyName ?? "لا توجد محفظة",
        style: const TextStyle(
          color: SpColor.accentBlue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBalanceDisplay(activeWallet, bool isLoading) {
    if (isLoading) return _buildShimmer(width: 180, height: 35, radius: 10);
    final currencyCode = activeWallet?.currency.code ?? "SYP";
    final balance = activeWallet?.balance ?? 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "$currencyCode ${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: SpColor.accentBlue.withAlpha(40),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.swap_vert_rounded,
            color: SpColor.accentBlue,
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    MainController controller,
    activeWallet,
    bool isLoading,
  ) {
    if (isLoading)
      return _buildShimmer(width: double.infinity, height: 60, radius: 20);

    final incomeTotal = controller.getFilteredIncomeTotal(activeWallet);
    final expenseTotal = controller.getFilteredExpenseTotal(activeWallet);
    final currencyCode = activeWallet?.currency.code ?? "";

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFlowStat(
              Icons.arrow_downward_rounded,
              "الدخل",
              "$currencyCode ${incomeTotal.toStringAsFixed(1)}",
              SpColor.incomeGreen,
            ),
          ),
          Container(width: 1, height: 25, color: Colors.white10),
          Expanded(
            child: _buildFlowStat(
              Icons.arrow_upward_rounded,
              "المصاريف",
              "$currencyCode ${expenseTotal.toStringAsFixed(1)}",
              SpColor.expenseRed,
            ),
          ),
        ],
      ),
    );
  }

  // دالة الـ Shimmer الأساسية
  Widget _buildShimmer({
    required double width,
    required double height,
    required double radius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.25),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildMonthPicker(MainController controller, BuildContext context) {
    final monthLabel = DateFormat(
      'MMMM yyyy',
      'ar',
    ).format(controller.incomesListController.dashboardMonth.value);
    return InkWell(
      onTap: () => controller.incomesListController.pickDashboardMonth(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              monthLabel,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStat(
    IconData icon,
    String label,
    String amount,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showWalletPicker(BuildContext context, MainController mainController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: SpColor.primaryDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "تبدل المحفظة النشطة",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      mainController.walletListController.regularWallets.length,
                  itemBuilder: (context, index) {
                    final wallet = mainController
                        .walletListController
                        .regularWallets[index];
                    final isSelected =
                        mainController.selectWallet.value?.walletId ==
                        wallet.walletId;
                    return ListTile(
                      onTap: () {
                        mainController.selectWallet.value = wallet;
                        Get.back();
                      },
                      title: Text(
                        "محفظة ${wallet.currency.currencyName}",
                        style: TextStyle(
                          color: isSelected ? SpColor.accentBlue : Colors.white,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: SpColor.accentBlue,
                            )
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
