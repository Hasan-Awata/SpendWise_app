import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/dashboard/presentation/budget_reports_view.dart';
import 'package:spendwise/features/ocr/receiptScannerScreen.dart';
import 'package:spendwise/features/widget_feature/helper_widget/quick_actions_row.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "أهلاً بك في SpendWise",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // القسم الأول: المالي
              _buildSectionTitle("إدارة الأموال"),
              _buildGrid([
                _FeatureItem(
                  "المحفظة",
                  Icons.account_balance_wallet,
                  Colors.blue,
                  () => Get.toNamed(Routes.LIST_WALLET),
                ),
                _FeatureItem(
                  "المصاريف",
                  Icons.receipt_long,
                  Colors.redAccent,
                  () => Get.toNamed(Routes.LIST_EXPENSE),
                ),
                _FeatureItem(
                  "الدخل",
                  Icons.attach_money,
                  Colors.green,
                  () => Get.toNamed(Routes.LIST_INCOME),
                ),
                _FeatureItem(
                  "الميزانية",
                  Icons.pie_chart,
                  Colors.orange,
                  () => Get.toNamed(Routes.CATEGORY_BUDGET),
                ),
              ]),

              const SizedBox(height: 20),

              // القسم الثاني: التخطيط والديون
              _buildSectionTitle("التخطيط والديون"),
              _buildGrid([
                _FeatureItem(
                  "الديون",
                  Icons.people_outline,
                  Colors.purple,
                  () => Get.toNamed(Routes.SHARED_DEBTS),
                ),
                _FeatureItem(
                  "أهداف الادخار",
                  Icons.savings,
                  Colors.teal,
                  () => Get.toNamed(Routes.GOAL_LIST),
                ),
                _FeatureItem(
                  "الالتزامات",
                  Icons.calendar_month,
                  Colors.indigo,
                  () => Get.toNamed(Routes.FIXEDOBLIGATIONS),
                ),
              ]),

              const SizedBox(height: 20),

              // القسم الثالث: الأدوات
              _buildSectionTitle("أدوات ذكية"),
              _buildGrid([
                _FeatureItem(
                  "مسح فواتير",
                  Icons.document_scanner,
                  SpColor.accentBlue,
                  () => Get.to(ReceiptScannerScreen()),
                ),
                _FeatureItem(
                  "الفئات",
                  Icons.category,
                  Colors.amber,
                  () => Get.to(CategoriesView()),
                ),
                _FeatureItem(
                  "تقارير",
                  Icons.bar_chart,
                  Colors.pink,
                  () => Get.to(BudgetReportsView()),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _buildGrid(List<_FeatureItem> items) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 3,
    mainAxisSpacing: 15,
    crossAxisSpacing: 15,
    children: items.map((item) => _buildFeatureCard(item)).toList(),
  );

  Widget _buildFeatureCard(_FeatureItem item) => GestureDetector(
    onTap: item.onTap,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 28),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _FeatureItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _FeatureItem(this.label, this.icon, this.color, this.onTap);
}
