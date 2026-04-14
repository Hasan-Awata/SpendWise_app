import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  WalletModel({
    super.walletId,
    required super.userId,
    required super.currency,
    required super.balance,
    required super.isSaved,
  });

  factory WalletModel.fromJson(Map<dynamic, dynamic> json) {
    return WalletModel(
      walletId: json["WalletId"] as int?,
      userId: json["UserId"] as int?,
      currency: _currencyFromWalletJson(json),
      balance: (json["Balance"] as num).toDouble(),
      isSaved: json['IsSaved'] ?? false,
    );
  }

  static Currency _currencyFromWalletJson(Map<dynamic, dynamic> json) {
    final nested = json["Currency"] ?? json["currency"];
    if (nested is Map) {
      return Currency.fromJson(Map<dynamic, dynamic>.from(nested));
    }
    final rawId = json["CurrencyId"] ?? json["currencyId"];
    if (rawId != null) {
      final id = (rawId as num).toInt();
      final resolved = CurrencyLocal().tryCurrencyById(id);
      if (resolved != null) return resolved;
    }
    return CurrencyLocal().allCurrencies[143];
  }

  Map<dynamic, dynamic> toJson() {
    return {
      "UserId": userId,
      "Currency": currency.toJson(),
      "Balance": balance,
      "IsSaved": isSaved,
    };
  }
}
