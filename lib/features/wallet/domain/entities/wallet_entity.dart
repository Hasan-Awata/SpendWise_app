import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

class WalletEntity {
  final int? walletId;
  final int? userId;
  final Currency currency;
  final double balance;
  final bool isSaved;

  WalletEntity({
    this.walletId,
    required this.userId,
    required this.currency,
    required this.balance,
    required this.isSaved,
  });
}
