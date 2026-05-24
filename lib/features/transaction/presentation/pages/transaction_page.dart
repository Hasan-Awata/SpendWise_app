import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';

import '../manager/transaction_controller.dart';
import '../widgets/transaction_tile.dart';

class TransactionPage extends GetView<TransactionController> {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    // Infinite scrolling hook detector
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller.fetchMoreTransactions();
      }
    });

    return Scaffold(
      backgroundColor: SpColor.surfaceNavy.withOpacity(0.5),
      appBar: AppBar(
        title: const Text(
          'Transaction Ledger',
          style: TextStyle(color: SpColor.offWhite),
        ),
        backgroundColor: SpColor.surfaceNavy,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: SpColor.incomeGreen),
          );
        }

        if (controller.transactions.isEmpty) {
          return const Center(
            child: Text(
              'No transactions mapped to your profile context.',
              style: TextStyle(color: SpColor.mutedGrey),
            ),
          );
        }

        return RefreshIndicator(
          color: SpColor.incomeGreen,
          onRefresh: () => controller.fetchInitialTransactions(),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(12),
            itemCount:
                controller.transactions.length +
                (controller.isLoadMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < controller.transactions.length) {
                final transaction = controller.transactions[index];

                return TransactionTile(transaction: transaction);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: SpColor.incomeGreen,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
            },
          ),
        );
      }),
    );
  }
}
