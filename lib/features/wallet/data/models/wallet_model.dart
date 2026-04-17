import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart' show Uuid;

class WalletModel extends WalletEntity {
  bool isSynced;
  String? localId;

  WalletModel({
    String? localId,
    super.walletId, // هذا int في الأب
    required super.userId, // هذا int في الأب
    required super.currency,
    required super.balance,
    required super.isSaved,
    this.isSynced = false,
  }) : localId = localId ?? const Uuid().v4();

  factory WalletModel.fromJson(Map<dynamic, dynamic> json) {
    // التأكد من تحويل القيم القادمة من JSON إلى int وتجنب الـ null
    return WalletModel(
      localId: const Uuid().v4(),
      walletId: json["walletId"],
      userId: (json["userId"] ?? json["UserId"] ?? -1) as int,
      balance: (json["balance"] ?? json["Balance"] ?? 0.0).toDouble(),
      isSaved: json['isSaved'] ?? json['IsSaved'] ?? false,
      isSynced: true,
      currency: _currencyFromWalletJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    userId = CurrentUser.user!.userId;
    return {
      "WalletId": walletId ?? -1,
      "UserId": userId,
      "Balance": balance,
      "IsSaved": isSaved,
      "CurrencyId": currency.id,
    };
  }

  factory WalletModel.fromLocal(Map<dynamic, dynamic> map) {
    // الإصلاح الجوهري هنا: التأكد من أن كل قيمة تُقرأ من Hive لها قيمة افتراضية ولا تعيد null
    return WalletModel(
      localId: map['localId'],
      walletId: (map['walletId'] ?? -1) as int,
      userId: (map['UserId'] ?? -1) as int,
      balance: (map['Balance'] ?? 0.0).toDouble(),
      isSaved: map['IsSaved'] == 1 || map['isSaved'] == true,
      isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
      currency: _currencyFromWalletJson(map),
    );
  }

  Map<dynamic, dynamic> toLocal() {
    return {
      "WalletId": walletId ?? -1,
      "localId": localId,
      "UserId": userId,
      "Balance": balance,
      "IsSaved": isSaved,
      "isSynced": isSynced,
      "Currency": {
        "CurrencyId": currency.id,
        "CurrencyName": currency.currencyName,
        "LiveValue": currency.actualValue,
      },
    };
  }

  static Currency _currencyFromWalletJson(Map<dynamic, dynamic> json) {
    final nested = json["Currency"] ?? json["currency"];
    if (nested is Map) {
      return Currency.fromJson(Map<dynamic, dynamic>.from(nested));
    }

    final rawId =
        json["CurrencyId"] ?? json["currencyId"] ?? json["currencyId"];
    if (rawId != null) {
      // تأمين التحويل لـ int لتجنب TypeError
      final id = int.tryParse(rawId.toString()) ?? 143;
      final resolved = CurrencyLocal().tryCurrencyById(id);
      if (resolved != null) return resolved;
    }
    return CurrencyLocal().allCurrencies[143];
  }

  @override
  String toString() {
    return '''WalletModel(
      localId: $localId, 
      walletId: $walletId, 
      userId: $userId, 
      balance: $balance, 
      currency: ${currency.currencyName}, 
      isSynced: $isSynced
    )''';
  }
}
