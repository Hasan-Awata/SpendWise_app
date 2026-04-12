import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class IncomeEntity {
  final int? id;
  final String title;

  final double amount;

  final String? description;

  final TagModel? tag;

  final DateTime date;

  final WalletModel? wallet;
  IncomeEntity({
    required this.title,
    required this.amount,
    required this.date,
    required this.tag,
    required this.description,
    this.wallet,
    this.id,
  });
}
