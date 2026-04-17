import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class IncomeEntity {
  final int? remoteId;

  int? userId;

  String title;

  double amount;

  String? description;

  TagModel? tag;

  DateTime date;

  WalletModel? wallet;
  IncomeEntity({
    this.remoteId,
    this.userId,
    this.wallet,
    required this.title,
    required this.amount,
    required this.date,
    required this.tag,
    required this.description,
  });
}
