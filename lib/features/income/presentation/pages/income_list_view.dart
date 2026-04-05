import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // // Helper: لتنسيق التاريخ والعملة
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import '../manager/income_controller.dart';

class IncomeListView extends StatelessWidget {
  const IncomeListView({super.key});

  @override
  Widget build(BuildContext context) {
    // // Logic: العثور على الكنترولر المحقون مسبقاً عبر الـ Binding
    final controller = Get.find<IncomeController>();

    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: AppBar(
        title: const Text(
          "Income History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        foregroundColor: SpColor.incomeGreen,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_sharp,
              color: SpColor.incomeGreen,
            ),
            onPressed: () {
              IncomeLocalDataSourceImpl().clear();
              controller.fetchAllIncomes();
            }, // Navigation: للانتقال لصفحة الإضافة
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SpColor.incomeGreen,
        child: Icon(Icons.add),
        onPressed: () {
          Get.toNamed('/add-income');
        },
      ),
      body: RefreshIndicator(
        color: SpColor.incomeGreen,
        onRefresh: () =>
            controller.fetchAllIncomes(), // // Logic: تحديث البيانات من السيرفر
        child: Obx(() {
          if (controller.isLoading.value && controller.incomesList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: SpColor.incomeGreen),
            );
          }

          if (controller.incomesList.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: controller.incomesList.length,
            itemBuilder: (context, index) {
              final income = controller.incomesList[index];
              return _buildIncomeCard(income);
            },
          );
        }),
      ),
    );
  }

  // // UI Component: بطاقة عرض الدخل بشكل احترافي
  Widget _buildIncomeCard(dynamic income) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // // UI: أيقونة تمثل نوع الدخل
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SpColor.incomeGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: SpColor.incomeGreen,
            ),
          ),
          const SizedBox(width: 16),
          // // UI: تفاصيل الدخل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd').format(income.lastTime),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          // // UI: المبلغ والعملة
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+${income.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: SpColor.incomeGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                income.currencyId == 0 ? "USD" : "SYP",
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // // UI Component: واجهة تظهر عند عدم وجود بيانات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          const Text(
            "No income records found",
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
