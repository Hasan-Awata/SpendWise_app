// [The model preserves the localId during JSON conversion to maintain identity across sync cycles]

import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart' show Uuid;

class WalletModel extends WalletEntity {
  bool isSynced;
  String? localId;

  WalletModel({
    this.localId,
    super.walletId,
    required super.userId,
    required super.currency,
    required super.balance,
    required super.isSaved,
    this.isSynced = false,
    super.currencyId,
  }) {
    // لا تولد UUID جديد إذا كان الـ localId موجوداً أصلاً
    localId ??= const Uuid().v4();
  }

  factory WalletModel.fromJson(Map<dynamic, dynamic> json) {
    return WalletModel(
      // ابحث عن localId في الـ JSON أولاً، إذا لم يوجد (بيانات جديدة من السيرفر) اترك المنشئ يولد واحداً
      localId: json["localId"],
      walletId: json["walletId"] ?? json["id"],
      userId: (json["userId"] ?? json["UserId"] ?? -1) as int,
      balance: (json["balance"] ?? json["Balance"] ?? 0.0).toDouble(),
      isSaved: json['isSaved'] ?? json['IsSaved'] ?? false,
      isSynced: true,
      currencyId: json["currencyId"] ?? json["CurrencyId"] ?? 1,
      currency: _currencyFromWalletJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "localId": localId, // أضف هذا لتتبع العنصر محلياً حتى بعد إرساله
      "walletId": walletId ?? -1,
      "userId": (CurrentUser.getUserId) ?? -1,
      "balance": balance,
      "isSaved": isSaved,
      "currencyId": currency.id,
    };
  }

  factory WalletModel.fromLocal(Map<dynamic, dynamic> json) {
    return WalletModel(
      // في البيانات المحلية، الـ localId ضروري جداً لمنع التكرار
      localId: json["localId"],
      walletId: json["walletId"],
      userId: (json["userId"] ?? -1) as int,
      balance: (json["balance"] ?? 0.0).toDouble(),
      isSaved: json['isSaved'] ?? false,
      isSynced: json['isSynced'] ?? true,
      currencyId: json["currencyId"] ?? 1,
      currency: _currencyFromWalletJson(json),
    );
  }

  Map<String, dynamic> toLocal() {
    return {
      "localId": localId, // تخزين المعرف المحلي في Hive
      "walletId": walletId ?? -1,
      "userId": (CurrentUser.getUserId) ?? -1,
      "balance": balance,
      "isSaved": isSaved,
      "isSynced": isSynced,
      "currencyId": currency.id,
    };
  }

  static Currency _currencyFromWalletJson(Map<dynamic, dynamic> json) {
    final cId = json["currencyId"] ?? json["CurrencyId"] ?? 1;
    return CurrencyLocal().allCurrencies.firstWhere(
      (c) => c.id == cId,
      orElse: () => Currency(id: 0, currencyName: "", actualValue: 0),
    );
  }

  @override
  String toString() {
    return '''WalletModel(
      localId: $localId, 
      currency:${currency.code}
      walletId: $walletId, 
      balance: $balance, 
      isSynced: $isSynced
    )''';
  }
}
