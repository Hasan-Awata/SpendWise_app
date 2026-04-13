import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/income/presentation/manager/income_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';

class BalanceCard extends GetView<IncomeController> {
  const BalanceCard({super.key});

  String _fmtMoney(double amount) {
    return 'SAR ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();

    return Obx(() {
      final walletsTotal = walletController.wallets.fold<double>(
        0,
        (sum, w) => sum + w.balance,
      );
      final monthLabel = DateFormat(
        'MMMM yyyy',
        'ar',
      ).format(controller.dashboardMonth.value);
      final incomeMonth = controller.monthlyIncomeTotal.value;

      return Container(
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
              color: SpColor.accentBlue.withValues(alpha: 0.1, blue: 1.6),
              blurRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    "إجمالي الرصيد",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.pickDashboardMonth(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            monthLabel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white70,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _fmtMoney(walletsTotal),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "الدخل المعروض حسب الشهر المحدد",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 17),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFlowStat(
                  Icons.arrow_downward,
                  "الدخل (الشهر)",
                  _fmtMoney(incomeMonth),
                  SpColor.incomeGreen,
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildFlowStat(
                  Icons.arrow_upward,
                  "المصاريف",
                  "SAR 0.00",
                  SpColor.expenseRed,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFlowStat(
    IconData icon,
    String label,
    String amount,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: SpColor.primaryDark,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: SpColor.offWhite,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
