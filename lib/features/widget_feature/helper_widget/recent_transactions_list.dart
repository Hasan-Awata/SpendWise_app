import 'package:flutter/material.dart';
import 'package:spendwise/features/transaction/presentation/widgets/transaction_tile.dart';

// الكلاس الأب: يعرض القائمة فقط
class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // كل عنصر هنا أصبح مستقلاً بحالته
        TransactionTile(
          title: "سوبر ماركت",
          tagName: "طعام - أهمية عالية",
          amount: 120.00,
          tagColor: Colors.red,
          icon: Icons.shopping_basket_outlined,
          date: DateTime.now(),
        ),
        TransactionTile(
          title: "تحويل راتب",
          tagName: "دخل أساسي",
          amount: 4.5000,
          tagColor: Colors.green,
          icon: Icons.account_balance_wallet_outlined,
          date: DateTime.now(),
        ),
        TransactionTile(
          title: "اشتراك نت",
          isExpense: false,
          tagName: "فواتير - أهمية متوسطة",
          amount: 200.00,
          tagColor: Colors.orange,
          icon: Icons.wifi,
          date: DateTime.now(),
        ),
      ],
    );
  }
}
