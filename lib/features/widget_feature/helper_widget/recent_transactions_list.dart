import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spendwise/features/transaction/presentation/manager/transaction_controller.dart';
import 'package:spendwise/features/transaction/presentation/widgets/transaction_tile.dart';

class RecentTransactionsList extends StatelessWidget {
  final bool showAll;

  RecentTransactionsList({super.key, this.showAll = false});

  final TransactionController transactionController =
      Get.find<TransactionController>();
  final NetworkService networkService = Get.find<NetworkService>();

  final IncomesListController incomeListController =
      Get.find<IncomesListController>();
  final ExpensesListController expenseListController =
      Get.find<ExpensesListController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // =========================
      // Loading State
      // =========================
      if (transactionController.isLoading.value) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: SpColor.surfaceNavy,
              highlightColor: SpColor.mutedGrey.withOpacity(0.15),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                height: 72,
                decoration: BoxDecoration(
                  color: SpColor.surfaceNavy,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        );
      }

      // =========================
      // Build raw list
      // =========================
      final List<dynamic> rawList = [];

      if (networkService.isOnline.value) {
        rawList.addAll(transactionController.transactions);
      } else {
        rawList.addAll(incomeListController.incomesList);
        rawList.addAll(expenseListController.expensesList);
      }

      // =========================
      // Remove duplicates safely
      // =========================
      final Set<String> seen = {};
      final List<dynamic> uniqueList = [];

      for (final item in rawList) {
        try {
          final key = (item.id != null)
              ? 'server_${item.id}'
              : 'local_${item.localId}';

          if (!seen.contains(key)) {
            seen.add(key);
            uniqueList.add(item);
          }
        } catch (_) {}
      }

      // =========================
      // Sort safely
      // =========================
      uniqueList.sort((a, b) {
        try {
          final DateTime da = a.date;
          final DateTime db = b.date;
          return db.compareTo(da);
        } catch (_) {
          return 0;
        }
      });

      final items = uniqueList.take(showAll ? uniqueList.length : 5).toList();

      // =========================
      // Empty state
      // =========================
      if (items.isEmpty) {
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

      // =========================
      // Build UI
      // =========================
      return Column(
        children: items.map((item) {
          // -------------------------
          // Online Transaction
          // -------------------------
          if (item is TransactionEntity) {
            return TransactionTile(transaction: item);
          }

          // -------------------------
          // Income Offline
          // -------------------------
          if (item is IncomeEntity) {
            return TransactionTile(
              transaction: TransactionEntity(
                id: item.id,
                localId: item.localId,
                userId: item.userId,
                title: item.title, // ✅ FIX: title correct
                amount: item.amount,
                date: item.date,
                description: item.description ?? '',
                walletId: item.walletId,
                walletLocalId: item.walletLocalId,
                expenseTagId: item.incomeTagId,
                isExpense: false,
                isSynced: item.isSynced,
              ),
            );
          }

          // -------------------------
          // Expense Offline
          // -------------------------
          if (item is ExpenseEntity) {
            return TransactionTile(
              transaction: TransactionEntity(
                id: item.id,
                localId: item.localId,
                userId: item.userId,
                title: item.title, // ✅ FIX: title correct
                amount: item.amount,
                date: item.date,
                description: item.description ?? '',
                walletId: item.walletId,
                walletLocalId: item.walletLocalId,
                categoryId: item.categoryId,
                expenseTagId: item.expenseTagId,
                isExpense: true,
                isSynced: item.isSynced,
              ),
            );
          }

          return const SizedBox.shrink();
        }).toList(),
      );
    });
  }
}
