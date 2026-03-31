import 'package:flutter/material.dart';
import 'package:spendwise/presentation/widgets/new/appbar.dart';
import 'package:spendwise/presentation/widgets/new/balance_card.dart';
import 'package:spendwise/presentation/widgets/new/bottom_nav_bar.dart';
import 'package:spendwise/presentation/widgets/new/quick_actions_row.dart';
import 'package:spendwise/presentation/widgets/new/recent_transactions_list.dart';
import 'package:spendwise/presentation/widgets/new/saving_goals_section.dart';
import 'package:spendwise/presentation/widgets/new/title_with_show.dart';
import 'package:spendwise/utils/colors.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0x00000000,
      ), // التأكد من أن خلفية الصفحة تتبع السمة الجديدة
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 2. قسم الكارت الرئيسي (إجمالي الرصيد والدخل والمصاريف)
            const BalanceCard(),

            const SizedBox(height: 30),

            // 3. شريط العمليات السريعة (الميزات الأساسية: OCR & QR)
            const QuickActionsRow(),

            const SizedBox(height: 30),

            // 4. قسم الأهداف الادخارية (مؤشر التقدم)
            const SavingsGoalsSection(),

            const SizedBox(height: 30),

            // 5. قائمة العمليات الأخيرة
            TitleWithShow(
              title: "آخر العمليات",
              onMorePressed: () {
                // TODO: الانتقال لصفحة التقارير الكاملة
              },
            ),
            const SizedBox(height: 15),
            const RecentTransactionsList(),

            const SizedBox(height: 100), // مساحة إضافية لتجنب تداخل الـ FAB
          ],
        ),
      ),
    );
  }
}

// Optimization: Using SpColor.primaryDark for the Scaffold background ensures no white flickering during transitions.
