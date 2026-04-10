import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  WalletModel({
    super.walletId,
    super.userId,
    required super.currencyId,
    required super.balance,
    // required super.title,
  });

  factory WalletModel.fromJson(Map<dynamic, dynamic> json) {
    return WalletModel(
      walletId: json["WalletId"],
      userId: json["UserId"],
      currencyId: json["CurrencyId"],
      balance: json["Balance"],
      // title: json["Title"],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      "WalletId": walletId,
      "UserId": userId,
      "CurrencyId": currencyId,
      "Balance": balance,
      // "Title": title,
    };
  }
}
