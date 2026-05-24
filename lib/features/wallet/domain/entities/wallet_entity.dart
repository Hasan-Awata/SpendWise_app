// wallet_entity.dart
import 'package:get/get.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:uuid/uuid.dart';

class WalletEntity {
  String localId;
  int? walletId;
  int userId;
  double balance;
  int currencyId;

  RxBool isSynced;
  bool isDeleted;
  bool isSaved;

  Currency currency;

  DateTime? createdAt;
  DateTime? updatedAt;

  WalletEntity({
    String? localId,
    RxBool? isSynced,
    this.walletId,
    required this.userId,
    required this.balance,
    required this.currencyId,
    this.isSaved = false,

    this.isDeleted = false,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  }) : isSynced = isSynced ?? false.obs,
       localId = localId ?? const Uuid().v4();

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
