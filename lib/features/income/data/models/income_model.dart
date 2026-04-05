import 'package:spendwise/features/income/domain/entities/income_entity.dart';

class IncomeModel extends IncomeEntity {
  IncomeModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.amount,
    required super.isFixed,
    required super.isMonthly,
    super.days,
    required super.lastTime,
    required super.currencyId,
  });

  // // Logic: Creating the model from JSON based on the latest Backend structure
  factory IncomeModel.fromJson(Map<dynamic, dynamic> json) {
    return IncomeModel(
      id: json['Id'] ?? 0,
      title: json['Title'] ?? '',
      amount: (json['Amount'] ?? 0).toDouble(),
      isFixed: json['IsFixed'] ?? false,
      isMonthly: json['IsMountly'] ?? false,
      days: json['Days'],
      lastTime: json['LastTime'] != null
          ? DateTime.parse(json['LastTime'])
          : DateTime.now(),
      currencyId: json["CurrencyId"],
      userId: json["UserID"],
    );
  }

  // // Logic: Converting the model back to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isFixed': isFixed,
      'isMountly': isMonthly,
      'days': days,
      'lastTime': lastTime.toIso8601String(),
      'CurrencyId': currencyId,
      "UserId": userId,
    };
  }
}
