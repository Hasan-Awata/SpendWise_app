import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/transaction/presentation/pages/add_tag_page.dart';
import 'package:spendwise/features/savings_goals/presentation/pages/add_saving_goal_page.dart';
import 'package:spendwise/features/transaction/presentation/pages/add_expense_view.dart';
import 'package:spendwise/features/transaction/presentation/pages/add_income_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark,
        elevation: 0,
        title: const Text(
          'Quick add',
          style: TextStyle(
            color: SpColor.accentBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: SpColor.accentBlue),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const Text(
            'Create something new',
            style: TextStyle(color: SpColor.mutedGrey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _DashboardTile(
            icon: Icons.tag_outlined,
            title: 'New tag',
            subtitle: 'Organize spending with tags',
            color: SpColor.accentBlue,
            onTap: () => Get.to(() => const AddtagPage()),
          ),
          _DashboardTile(
            icon: Icons.savings_outlined,
            title: 'New saving goal',
            subtitle: 'Set a target and track progress',
            color: const Color(0xFFF59E0B),
            onTap: () => Get.to(() => const AddSavingGoalPage()),
          ),
          _DashboardTile(
            icon: Icons.trending_up,
            title: 'New income',
            subtitle: 'Record money in',
            color: SpColor.incomeGreen,
            onTap: () => Get.to(() => AddIncomeView()),
          ),
          _DashboardTile(
            icon: Icons.trending_down,
            title: 'New expense',
            subtitle: 'Record money out',
            color: SpColor.expenseRed,
            onTap: () => Get.to(() => const AddExpenseView()),
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: SpColor.surfaceNavy,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: SpColor.offWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: SpColor.mutedGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: SpColor.mutedGrey.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
