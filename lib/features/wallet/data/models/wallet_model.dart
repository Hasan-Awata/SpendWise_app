import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart' show Uuid;

// تم فصل منطق التخزين المحلي عن منطق السيرفر لضمان مرونة البيانات وتجنب الأخطاء
class WalletModel extends WalletEntity {
  bool isSynced;
  String localId;

  WalletModel({
    String? localId,
    super.walletId,
    super.userId,
    required super.currency,
    required super.balance,
    required super.isSaved,
    this.isSynced = false,
  }) : localId = localId ?? const Uuid().v4();

  // هذه الدالة (الموجودة مسبقاً) تتعامل مع البيانات القادمة من السيرفر (API)
  factory WalletModel.fromJson(Map<dynamic, dynamic> json) {
    return WalletModel(
      localId: const Uuid()
          .v4(), // السيرفر لا يعرف الـ localId لذا ننشئ واحداً جديداً
      walletId: json["walletId"] ?? -1,
      currency: _currencyFromWalletJson(json),
      balance: (json["balance"] as num)
          .toDouble(), // تأمين تحويل الرقم إلى double
      isSaved: json['isSaved'] ?? false,
      isSynced: true, // البيانات القادمة من السيرفر تعتبر متزامنة
    );
  }

  // هذه الدالة (الموجودة مسبقاً) مخصصة لإرسال البيانات إلى السيرفر
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "balance": balance,
      "isSaved": isSaved,
      "currency": {
        "currencyId": currency.id,
        "currencyName": currency.currencyName,
        "liveValue": currency.actualValue,
      },
    };
  }

  // دالة جديدة: لتحويل البيانات المخزنة محلياً (Database/Hive) إلى Model
  factory WalletModel.fromLocal(Map<dynamic, dynamic> map) {
    return WalletModel(
      localId: map['localId'],
      walletId: map['walletId'],
      userId: map['userId'],
      balance: (map['balance'] as num).toDouble(),
      isSaved: map['isSaved'] == 1 || map['isSaved'] == true,
      isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
      currency: _currencyFromWalletJson(
        map,
      ), // نستخدم نفس المنطق لاستخراج العملة
    );
  }

  // دالة جديدة: لتحويل الـ Model إلى شكل مناسب للحفظ في التخزين المحلي
  Map<dynamic, dynamic> toLocal() {
    return {
      "localId": localId,
      "walletId": walletId,
      "userId": userId,
      "balance": balance,
      "isSaved": isSaved
          ? 1
          : 0, // تخزين كـ Integer للقواعد التي لا تدعم Boolean
      "isSynced": isSynced ? 1 : 0,
      "currencyId":
          currency.id, // يكفي تخزين المعرف لاسترجاعه من CurrencyLocal لاحقاً
    };
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
}
