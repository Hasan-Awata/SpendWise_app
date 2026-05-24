// lib/features/home/presentation/pages/home_page.dart
// Home: Dashboard UI container integrating modern async state hooks for real-time financial tracking

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/transaction/presentation/manager/transaction_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/balance_card.dart';
import 'package:spendwise/features/widget_feature/helper_widget/quick_actions_row.dart';
import 'package:spendwise/features/widget_feature/helper_widget/recent_transactions_list.dart';
import 'package:spendwise/features/widget_feature/helper_widget/saving_goals_section.dart';
import 'package:spendwise/features/widget_feature/helper_widget/title_with_show.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = MainController.instance;

  // Injection of the updated reactive transaction pipeline controller context
  final transactionController = Get.put(
    TransactionController(getTransactionsUseCase: Get.find()),
  );

  @override
  Widget build(BuildContext context) {
    controller.showAll.value = false;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: SpColor.accentBlue,
        backgroundColor: SpColor.surfaceNavy,
        onRefresh: () async {
          // Trigger concurrent repository cache refreshes across your architecture domains
          await controller.refreshAllData();
          await transactionController.fetchInitialTransactions();
          controller.showAll.value = false;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // كارت الرصيد المحدث (صافي الربح: دخل - مصاريف)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: const BalanceCard(),
              ),

              const SizedBox(height: 30),

              // شريط العمليات السريعة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: const QuickActionsRow(),
              ),

              const SizedBox(height: 30),

              // قسم أهداف الادخار
              const SavingsGoalsSection(),

              const SizedBox(height: 30),

              // عنوان العمليات الأخيرة مع زر عرض المزيد
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Obx(
                  () => controller.showAll.value
                      ? const SizedBox()
                      : TitleWithShow(
                          title: "آخر العمليات",
                          onMorePressed: () {
                            controller.showAll.value = true;
                          },
                        ),
                ),
              ),

              const SizedBox(height: 15),

              // القائمة المدمجة المستقرة المحدثة برابط تفاعلي مع GetX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Obx(
                  () =>
                      RecentTransactionsList(showAll: controller.showAll.value),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
