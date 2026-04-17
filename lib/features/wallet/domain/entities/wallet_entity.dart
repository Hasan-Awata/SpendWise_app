import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

class WalletEntity {
  int? walletId;
  int userId;
  final Currency currency;
  double balance;
  final bool isSaved;

  WalletEntity({
    this.walletId,
    required this.userId,
    required this.currency,
    required this.balance,
    required this.isSaved,
  });
}
