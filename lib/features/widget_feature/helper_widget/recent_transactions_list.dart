// lib/features/transaction/presentation/widgets/recent_transactions_list.dart
// RecentTransactionsList: Refactored state stream triggers by scoping filter frames inside the reactive Obx builder

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spendwise/features/transaction/presentation/manager/transaction_controller.dart';
import 'package:spendwise/features/transaction/presentation/widgets/transaction_tile.dart';

class RecentTransactionsList extends StatelessWidget {
  final bool showAll;

  RecentTransactionsList({super.key, this.showAll = false});

  // من الأفضل جعل الـ Controller نهائي (final) واستدعائه عند الإنشاء
  final TransactionController transactionController =
      Get.find<TransactionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final seenLocalIds = <String>{};
      final transactions = transactionController.transactions;
      final List<TransactionEntity> uniqueTransactions = [];

      for (var transaction in transactions) {
        if (!seenLocalIds.contains(transaction.localId)) {
          seenLocalIds.add(transaction.localId!);
          uniqueTransactions.add(transaction);
        }
      }

      uniqueTransactions.sort((a, b) => b.date.compareTo(a.date));

      // 3. تحديد كمية العناصر المطلوب عرضها (5 عناصر للرئيسية أو كامل القائمة)
      final latestTransactions = uniqueTransactions
          .take(showAll ? uniqueTransactions.length : 5)
          .toList();

      if (transactionController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: SpColor.incomeGreen),
        );
      }
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
        children: latestTransactions.map((transaction) {
          return TransactionTile(transaction: transaction);
        }).toList(),
      );
    });
  }
}
