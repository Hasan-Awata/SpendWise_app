import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';

import 'package:spendwise/features/transaction/presentation/widgets/transaction_tile.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final incomeController = Get.find<IncomesListController>();
    final expenseController = Get.find<ExpensesListController>();

    return Obx(() {
      final List<dynamic> combinedList = [
        ...incomeController.incomesList,
        ...expenseController.expensesList,
      ];

      combinedList.sort((a, b) => b.date.compareTo(a.date));

      final latestTransactions = combinedList.take(5).toList();

      if (latestTransactions.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Text(
              "لا توجد عمليات مضافة لهذا الشهر",
              style: TextStyle(color: Colors.white54),
            ),
          ),
        );
      }

      return Column(
        children: latestTransactions.map((item) {
          final bool isExpense = item is ExpenseModel;

          return TransactionTile(
            title: item.title,
            amount: item.amount,
            date: item.date,
            isExpense: isExpense,
            tagName: _getTagName(item),
            tagColor: isExpense ? SpColor.expenseRed : SpColor.incomeGreen,
            icon: isExpense
                ? Icons.shopping_bag_outlined
                : Icons.account_balance_wallet_outlined,
          );
        }).toList(),
      );
    });
  }

  String _getTagName(dynamic item) {
    if (item.tag == null) return "بدون وسم";

    if (item.tag is String) return item.tag;

    try {
      return item.tag.name ?? "عام";
    } catch (_) {
      return "عام";
    }
  }
}
