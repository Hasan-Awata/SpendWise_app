import 'package:flutter/material.dart';
import 'package:spendwise/presentation/widgets/mixin/scalable_state.dart';
import 'package:spendwise/utils/colors.dart';
import 'package:spendwise/utils/constants.dart';

class TransactionTile extends StatefulWidget {
  final String title;
  final String categoryName;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color categoryColor;
  final bool isExpense;

  const TransactionTile({
    super.key,
    required this.title,
    required this.categoryName,
    required this.amount,
    required this.date,
    required this.icon,
    required this.categoryColor,
    this.isExpense = true,
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> with ScalableState {
  @override
  Widget build(BuildContext context) {
    return wrapWithScale(
      scaleFactor: 1.05,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 2,
        ), // تقليل المسافات العمودية قليلاً
        decoration: BoxDecoration(
          color: SpColor
              .surfaceNavy, // جعل البطاقة أفتح قليلاً من الخلفية الأساسية
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            scale == 1.0
                ? BoxShadow()
                : widget.isExpense
                ? BoxShadow(color: SpColor.expenseRed, blurRadius: 6)
                : BoxShadow(color: SpColor.incomeGreen, blurRadius: 6),
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
              // استخدام لون الفئة بوضوح خلف الأيقونة
              color: widget.categoryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.categoryColor, size: 22),
          ),

          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: SpColor.offWhite, // استخدام الأبيض المريح
            ),
          ),
          subtitle: Text(
            "${widget.categoryName} • ${widget.date.day}/${widget.date.month}/${widget.date.year}",
            style: const TextStyle(
              color: SpColor.mutedGrey, // استخدام الرمادي المطفأ الجديد
              fontSize: 12,
            ),
          ),

          trailing: DefaultTextStyle(
            style: SpConstants.numStyle(widget.isExpense),
            child: Text(
              "${widget.isExpense ? '-' : '+'} \$${widget.amount.toStringAsFixed(2)}",
            ),
          ),
        ),
      ),
    );
  }
}

// TransactionTile now feels more integrated with the overall SpendWise aesthetic.
