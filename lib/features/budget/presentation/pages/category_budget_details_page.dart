import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';

class CategoryBudgetDetailsPage extends StatelessWidget {
  final CategoryBudgetEntity budget;

  const CategoryBudgetDetailsPage({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final progress = (budget.percentageProgress / budget.percentageLimit).clamp(
      0.0,
      1.0,
    );

    final remaining = budget.percentageLimit - budget.percentageProgress;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),

      // =========================================================
      // AppBar
      // =========================================================
      appBar: AppBar(
        title: const Text("تفاصيل ميزانية القسم"),
        backgroundColor: const Color(0xff5669FF),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =====================================================
            // Header Card
            // =====================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff5669FF), Color(0xff7A88FF)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "القسم رقم ${budget.categoryId}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    budget.isActive ? "نشطة" : "غير نشطة",
                    style: TextStyle(
                      color: budget.isActive
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // Progress Card
            // =====================================================
            _InfoCard(
              title: "نسبة الاستخدام",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Color(0xff5669FF)),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "المستخدم: ${budget.percentageProgress.toStringAsFixed(1)}%",
                      ),
                      Text(
                        "الحد: ${budget.percentageLimit.toStringAsFixed(1)}%",
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "المتبقي: ${remaining.toStringAsFixed(1)}%",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =====================================================
            // Dates Card
            // =====================================================
            _InfoCard(
              title: "الفترة الزمنية",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 18),
                      const SizedBox(width: 8),
                      Text(DateFormat('yyyy/MM/dd').format(budget.startDate)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 18),
                      const SizedBox(width: 8),
                      Text(DateFormat('yyyy/MM/dd').format(budget.endDate)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =====================================================
            // Status Card
            // =====================================================
            _InfoCard(
              title: "الحالة",
              child: Row(
                children: [
                  Icon(
                    budget.isActive ? Icons.check_circle : Icons.cancel,
                    color: budget.isActive ? Colors.green : Colors.red,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    budget.isActive ? "ميزانية فعالة" : "ميزانية متوقفة",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =====================================================
            // Buttons
            // =====================================================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: () {
                      // Navigate to update page
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("تعديل"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: () {
                      // Delete action
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("حذف"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// Reusable Info Card
// =============================================================
class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }
}
