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
    return Currency(
      id: json['id'],
      code: json['Code'],
      currencyName: json['CurrencyName'] as String,
      actualValue: json['LiveValue'] ?? 0.0,
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      "CurrencyId": id,
      // 'Code': code,
      "CurrencyName": currencyName,
      "LiveValue": actualValue,
    };
  }
}
