import 'package:isar/isar.dart';

part 'currency_model.g.dart';

@collection
class Currency {
  Id get isarId => id ?? 0;
  // في Isar Embedded، لا نحتاج لـ Id id، لكننا سنحتفظ بالـ id الخاص بالسيرفر
  int? id;

  String? code;

  String? currencyName;

  double? actualValue;

  Currency({this.id, this.code, this.currencyName, this.actualValue});

  // ========================= FROM JSON (API) =========================
  factory Currency.fromJson(Map<String, dynamic> json) {
    final rawValue = json['LiveValue'] ?? json['actualValue'] ?? 0.0;
    return Currency(
      id: json['CurrencyId'] ?? json['id'] ?? 140,
      code: json['Code'] ?? json['code'] ?? "",
      currencyName: json['CurrencyName'] ?? json['currencyName'] ?? "",
      actualValue: (rawValue is num) ? rawValue.toDouble() : 0.0,
    );
  }

  // ========================= TO JSON (API) =========================
  Map<String, dynamic> toJson() {
    return {
      "CurrencyId": id,
      "Code": code,
      "CurrencyName": currencyName,
      "LiveValue": actualValue,
    };
  }

  @override
  String toString() {
    return 'Currency(id: $id, name: $currencyName, code: $code, value: $actualValue)';
  }
}
