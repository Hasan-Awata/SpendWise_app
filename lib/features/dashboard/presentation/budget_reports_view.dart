import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/budget/presentation/manager/category_budget_list_controller.dart';

class BudgetReportsView extends StatelessWidget {
  BudgetReportsView({super.key});

  final CategoryBudgetListController controller =
      Get.find<CategoryBudgetListController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        title: const Text("تقرير الميزانية"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SpColor.accentBlue,
        onPressed: () {
          _showProgressDetails();
        },
        child: const Icon(Icons.analytics_outlined, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            const SizedBox(height: 20),
            // المخطط الدائري
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _buildChartSections(),
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // قائمة الملخص
            Expanded(
              child: ListView.builder(
                itemCount: controller.budgets.length,
                itemBuilder: (context, index) {
                  final item = controller.budgets[index];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: _getColor(index)),
                    title: Text(
                      "فئة ${item.categoryId}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      "${item.percentageLimit}%",
                      style: const TextStyle(color: SpColor.accentBlue),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    return controller.budgets.map((b) {
      final index = controller.budgets.indexOf(b);
      return PieChartSectionData(
        color: _getColor(index),
        value: b.percentageLimit,
        title: '${b.percentageLimit.toInt()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColor(int index) {
    const colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    return colors[index % colors.length];
  }

  void _showProgressDetails() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "مراقبة التقدم الفعلي",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: controller.budgets.length,
                itemBuilder: (context, index) {
                  final item = controller.budgets[index];
                  // ملاحظة: استبدل 0.6 بقيمة المصروف الفعلي الحقيقية
                  double progress = (0.6).clamp(0.0, 1.0);

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "فئة ${item.categoryId}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white12,
                        color: progress > 0.8
                            ? Colors.redAccent
                            : Colors.greenAccent,
                      ),
                      const SizedBox(height: 15),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
