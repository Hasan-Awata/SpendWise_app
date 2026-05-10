// wallet_entity.dart
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:uuid/uuid.dart';

class WalletEntity {
  String localId;
  int? walletId;
  int userId;
  double balance;
  int currencyId;

  bool isSynced;
  bool isDeleted;
  bool isSaved;

  Currency currency;

  DateTime? createdAt;
  DateTime? updatedAt;

  WalletEntity({
    String? localId,
    this.walletId,
    required this.userId,
    required this.balance,
    required this.currencyId,
    this.isSaved = false,
    this.isSynced = false,
    this.isDeleted = false,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  }) : localId = localId ?? const Uuid().v4();

  @override
  String toString() {
    return """
localId:$localId
      walletId:$walletId
      userId: $userId,
      balance: $balance,
      currencyId: $currencyId,
      isSaved: $isSaved,
      currency:${currency.currencyName}
""";
  }
}
