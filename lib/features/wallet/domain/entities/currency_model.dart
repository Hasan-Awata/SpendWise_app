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
      id: (json['id'] as num).toInt(),
      code: json['Code'],
      currencyName: json['CurrencyName'] as String,
      actualValue: (json['ActualValue'] as num).toDouble(),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      "id": id,
      'Code': code,
      "CurrencyName": currencyName,
      "ActualValue": actualValue,
    };
  }
}
