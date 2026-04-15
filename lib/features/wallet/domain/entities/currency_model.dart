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
      id: (json['CurrencyId'] ?? json['id']) as int,
      code: (json['Code'] ?? json['code']) as String?,
      currencyName: (json['CurrencyName'] ?? json['currencyName']) as String,
      actualValue: (rawValue as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "CurrencyId": id,
      "CurrencyName": currencyName,
      "LiveValue": actualValue,
    };
  }

  @override
  String toString() {
    return 'Currency(id: $id, name: $currencyName, code: $code, value: $actualValue)';
  }
}
