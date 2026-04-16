import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';

import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/balance_card.dart';
import 'package:spendwise/features/widget_feature/helper_widget/quick_actions_row.dart';
import 'package:spendwise/features/widget_feature/helper_widget/recent_transactions_list.dart';
import 'package:spendwise/features/widget_feature/helper_widget/saving_goals_section.dart';
import 'package:spendwise/features/widget_feature/helper_widget/title_with_show.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          // استدعاء الدوال المسؤولة عن تحديث البيانات من السيرفر والمزامنة
          await Get.find<WalletsListController>().loadWallets();
          await Get.find<IncomesListController>().fetchAllIncomes();
          await Get.find<ExpensesListController>().fetchExpenses();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // كارت الرصيد المحدث (صافي الربح: دخل - مصاريف)
              const BalanceCard(),

              const SizedBox(height: 30),

              // شريط العمليات السريعة
              const QuickActionsRow(),

              const SizedBox(height: 30),

              // قسم أهداف الادخار
              const SavingsGoalsSection(),

              const SizedBox(height: 30),

              // عنوان العمليات الأخيرة مع زر عرض المزيد
              TitleWithShow(
                title: "آخر العمليات",
                onMorePressed: () {
                  // يمكن توجيهه لصفحة السجل الكامل لاحقاً
                },
              ),

              const SizedBox(height: 15),

              // القائمة المدمجة (دخل + مصاريف) مرتبة زمنياً
              const RecentTransactionsList(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
