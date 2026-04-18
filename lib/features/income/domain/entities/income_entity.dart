import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class IncomeEntity {
  int? id;
  int userId;
  String title;
  int walletId;
  double amount;
  DateTime date;
  int? incomeTagId;
  String description;
  WalletModel? wallet;
  TagModel? tag;

  IncomeEntity({
    this.id = -1,
    required this.userId,
    this.wallet,
    this.walletId = -1,
    required this.title,
    required this.amount,
    required this.date,
    this.incomeTagId,
    required this.description,
    this.tag,
  });
}
