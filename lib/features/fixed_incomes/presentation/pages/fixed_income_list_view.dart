// lib/features/fixed_income/presentation/pages/fixed_Income_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/fixed_incomes/presentation/manager/fixed_income_controller.dart'
    show FixedIncomeController;
import 'package:spendwise/features/fixed_incomes/presentation/manager/fixed_income_list_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class FixedIncomeListView extends StatelessWidget {
  const FixedIncomeListView({super.key});

  @override
  Widget build(BuildContext context) {
    // تأكد من ضبط Controller الخاص بك في الـ Binding
    final controller = Get.find<FixedIncomeListController>();

    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        foregroundColor: SpColor.incomeGreen,
        title: const Text(
          "الدخل الثابت",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SpColor.incomeGreen,
        onPressed: () => Get.toNamed('/add-fixed-income'),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "إضافة دخل",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.incomesList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: SpColor.incomeGreen),
          );
        }

        if (controller.incomesList.isEmpty) {
          return Center(
            child: ListView(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const Center(
                  child: Text(
                    "لا يوجد دخل ثابت حالياً",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => controller.fetchIncomes(),
                    child: const Text(
                      "إعادة المحاولة",
                      style: TextStyle(color: SpColor.incomeGreen),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: SpColor.incomeGreen,
          onRefresh: () => controller.fetchIncomes(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: controller.incomesList.length,
            itemBuilder: (context, index) {
              final income = controller.incomesList[index];
              return _buildIncomeItem(income, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildIncomeItem(
    FixedIncomeModel income,
    FixedIncomeListController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(child: _buildDetails(income)),
          const SizedBox(width: 12),
          _buildActions(income, controller),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [SpColor.incomeGreen, SpColor.incomeGreen.withOpacity(0.7)],
        ),
      ),
      child: const Icon(
        Icons.account_balance_wallet_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildDetails(FixedIncomeModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title.trim().isEmpty ? 'بدون عنوان' : item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "يوم: ${item.days} | آخر: ${DateFormat('MM/dd').format(item.lastTime)}",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _activeStatus(item.isActive),
      ],
    );
  }

  Widget _activeStatus(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.12)
            : Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'نشط' : 'متوقف',
        style: TextStyle(
          color: isActive ? Colors.greenAccent : Colors.redAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActions(
    FixedIncomeModel item,
    FixedIncomeListController controller,
  ) {
    final curreny =
        Get.find<WalletsListController>().wallets
            .firstWhereOrNull((w) => w.walletId == item.walletId)
            ?.currency
            .code ??
        "No Code";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${item.amount.toStringAsFixed(2)} $curreny",
          style: const TextStyle(
            color: SpColor.incomeGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(width: 6),
        _iconBtn(Icons.delete, Colors.redAccent, () {
          _showDeleteDialog(item);
        }),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // واجهة تأكيد الحذف
  void _showDeleteDialog(FixedIncomeModel item) {
    final controller = Get.find<FixedIncomeController>();

    Get.defaultDialog(
      backgroundColor: SpColor.surfaceNavy,

      title: "حذف الدخل",
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      middleText:
          "هل أنت متأكد من حذف هذا الدخل الثابت؟ لا يمكن التراجع عن هذا الإجراء.",
      textConfirm: "حذف",
      textCancel: "إلغاء",

      middleTextStyle: TextStyle(color: SpColor.offWhite),
      confirmTextColor: SpColor.offWhite,
      buttonColor: SpColor.incomeGreen,
      onConfirm: () async {
        await controller.deleteFixedIncome(item);
        Get.back(); // إغلاق الـ Dialog
      },
    );
  }
}
