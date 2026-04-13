import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // // Helper: لتنسيق التاريخ والعملة
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import '../manager/income_controller.dart';

class IncomeListView extends GetView<IncomeController> {
  const IncomeListView({super.key});

  @override
  Widget build(BuildContext context) {
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
              controller.clearAllIncomes();
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
        key: controller.refreshIndicatorKey,
        color: SpColor.incomeGreen,
        onRefresh: () async {
          controller.fetchAllIncomes(isRefresh: true);
        },
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
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
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
  Widget _buildIncomeCard(IncomeModel income) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // // UI: أيقونة تمثل نوع الدخل
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SpColor.incomeGreen.withValues(alpha: 0.1),
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
                  DateFormat('yyyy-MM-dd').format(income.date),
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
                income.wallet?.currency.currencyName ?? "—",
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(), // هذا السطر هو المفتاح
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No income records found",
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
