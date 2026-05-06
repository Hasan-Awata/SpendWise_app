import 'package:hive/hive.dart';

class Currency extends HiveObject {
  final int id;

  final String? code;

  final String currencyName;

  final double actualValue;

  Currency({
    required this.id,
    this.code,
    required this.currencyName,
    required this.actualValue,
  });

  factory Currency.fromJson(Map<dynamic, dynamic> json) {
    final rawValue = json['LiveValue'] ?? json['actualValue'] ?? 0.0;
    return Currency(
      id: json['CurrencyId'] ?? 140,
      code: json['Code'] ?? json['code'] ?? "",
      currencyName: json['CurrencyName'] ?? json['currencyName'] ?? "",
      actualValue: rawValue,
    );
  }

  Map<dynamic, dynamic> toJson() {
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
