import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  WalletModel({
    super.walletId,
    super.userId,
    required super.currency,
    required super.balance,
    super.title = "",
  });

  factory WalletModel.fromJson(Map<dynamic, dynamic> json) {
    return WalletModel(
      walletId: json["WalletId"],
      userId: json["UserId"],
      currency: Currency(id: 0, currencyName: "NO-CURRENYC", actualValue: 1),
      balance: json["Balance"],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      "WalletId": walletId,
      "UserId": userId,
      "CurrencyId": currency.id,
      "Balance": balance,
    };
  }
}
