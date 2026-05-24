import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/core/utils/constants.dart' show SpConstants;
import 'package:spendwise/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spendwise/features/widget_feature/mixin/scalable_state.dart';

class TransactionTile extends StatefulWidget {
  final TransactionEntity transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> with ScalableState {
  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    final String displayTitle = transaction.title.isEmpty
        ? "No Title"
        : transaction.title;
    final double displayAmount = transaction.amount;
    final DateTime displayDate = transaction.date;
    final bool isExpense = transaction.isExpense;
    final String currency = transaction.currency;

    // اسم الفئة القادم من الـ Category أو قيمة افتراضية في حال كانت null
    final String tagName = transaction.category?.name ?? "General";

    // =================================================================
    // تحديد الألوان والأيقونات ديناميكياً بناءً على نوع المعاملة (دخل أو مصروف)
    // =================================================================
    final Color tagColor = isExpense ? SpColor.expenseRed : SpColor.incomeGreen;
    final IconData icon = isExpense
        ? Icons
              .arrow_outward_rounded // سهم خارج أحمر للمصاريف
        : Icons.arrow_downward_rounded; // سهم داخل أخضر للإيرادات/الدخل

    return wrapWithScale(
      scaleFactor: 1.05,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: SpColor.surfaceNavy,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            scale == 1.0
                ? const BoxShadow(color: Colors.transparent)
                : isExpense
                ? const BoxShadow(color: SpColor.expenseRed, blurRadius: 6)
                : const BoxShadow(color: SpColor.incomeGreen, blurRadius: 6),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tagColor, size: 22),
          ),
          title: Text(
            displayTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: SpColor.offWhite,
            ),
          ),
          subtitle: Text(
            "$tagName • ${displayDate.day}/${displayDate.month}/${displayDate.year}",
            style: const TextStyle(color: SpColor.mutedGrey, fontSize: 12),
          ),
          trailing: DefaultTextStyle(
            style: SpConstants.numStyle(isExpense),
            child: Text(
              "$currency ${isExpense ? '-' : '+'} \$${displayAmount.toStringAsFixed(2)}",
            ),
          ),
        ),
      ),
    );
  }
}
