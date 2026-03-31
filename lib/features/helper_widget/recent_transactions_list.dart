import 'package:flutter/material.dart';
import 'package:spendwise/presentation/widgets/mixin/scalable_state.dart';
import 'package:spendwise/presentation/widgets/supwidgets/transaction_tile.dart';
import 'package:spendwise/utils/colors.dart';

// الكلاس الأب: يعرض القائمة فقط
class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // كل عنصر هنا أصبح مستقلاً بحالته
        TransactionTile(
          title: "سوبر ماركت",
          categoryName: "طعام - أهمية عالية",
          amount: 120.00,
          categoryColor: Colors.red,
          icon: Icons.shopping_basket_outlined,
          date: DateTime.now(),
        ),
        TransactionTile(
          title: "تحويل راتب",
          categoryName: "دخل أساسي",
          amount: 4.5000,
          categoryColor: Colors.green,
          icon: Icons.account_balance_wallet_outlined,
          date: DateTime.now(),
        ),
        TransactionTile(
          title: "اشتراك نت",
          isExpense: false,
          categoryName: "فواتير - أهمية متوسطة",
          amount: 200.00,
          categoryColor: Colors.orange,
          icon: Icons.wifi,
          date: DateTime.now(),
        ),
      ],
    );
  }
}
