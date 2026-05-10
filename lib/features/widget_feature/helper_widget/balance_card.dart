// // [تم تحديث الكلاس بالكامل: إضافة أيقونة تبديل تفاعلية، تحسين واجهة اختيار المحفظة باستخدام Bottom Sheet، وتنسيق الألوان لتعزيز تجربة المستخدم]
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  final expensesController = Get.find<ExpensesListController>();
  final incomesListController = Get.find<IncomesListController>();
  final walletListController = Get.find<WalletsListController>();
  final mainController = Get.find<MainController>();

  @override
  void initState() {
    super.initState();
    // تعيين المحفظة الأولى كافتراضية إذا لم تكن مختارة مسبقاً
    if (walletListController.wallets.isNotEmpty &&
        mainController.selectWallet.value == null) {
      mainController.selectWallet.value = walletListController.wallets[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWalletPicker(),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "إجمالي الرصيد الحقيقي",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // مؤشر بصري يوضح اسم المحفظة النشطة حالياً
                    Obx(() {
                      final walletName =
                          mainController
                              .selectWallet
                              .value
                              ?.currency!
                              .currencyName ??
                          "اختر محفظة";
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: SpColor.accentBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          walletName,
                          style: const TextStyle(
                            color: SpColor.accentBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                // زر اختيار التاريخ
                Obx(() {
                  final monthLabel = DateFormat(
                    'MMMM yyyy',
                    'ar',
                  ).format(incomesListController.dashboardMonth.value);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          incomesListController.pickDashboardMonth(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.white70,
                              size: 16,
                            ),
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
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 15),
            // عرض الرصيد مع أيقونة التبديل
            Obx(() {
              final wallet = mainController.selectWallet.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      wallet == null
                          ? "0.00"
                          : "${wallet.currency!.code} ${wallet.balance}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // أيقونة تدل على أن القسم قابل للضغط والتبديل
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: SpColor.accentBlue,
                      size: 22,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            // إحصائيات التدفق المالي
            Obx(() {
              final income = incomesListController.monthlyAndWalletIncome.value;
              final expense = expensesController.monthlyAndWalletExpense.value;
              final wallet = mainController.selectWallet.value;
              final currencyCode = wallet?.currency!.code ?? "";

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
                        "$currencyCode $income",
                        SpColor.incomeGreen,
                      ),
                    ),
                    Container(width: 1, height: 25, color: Colors.white10),
                    Expanded(
                      child: _buildFlowStat(
                        Icons.arrow_upward_rounded,
                        "المصاريف",
                        "$currencyCode $expense",
                        SpColor.expenseRed,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // استخدام Bottom Sheet بدلاً من Dialog لتجربة مستخدم أفضل على الموبايل
  void _showWalletPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: SpColor.primaryDark2,
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
              "تبديل المحفظة النشطة",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: walletListController.wallets.length,
                itemBuilder: (context, index) {
                  final wallet = walletListController.wallets[index];
                  final isSelected =
                      mainController.selectWallet.value?.walletId ==
                      wallet.walletId;
                  return ListTile(
                    onTap: () {
                      mainController.selectWallet.value = wallet;
                      Get.back();
                    },
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? SpColor.accentBlue.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: isSelected ? SpColor.accentBlue : Colors.white54,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      "محفظة ${wallet.currency!.currencyName}",
                      style: TextStyle(
                        color: isSelected ? SpColor.accentBlue : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: SpColor.accentBlue,
                            size: 20,
                          )
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
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
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
