import 'package:spendwise/features/income/domain/entities/income_entity.dart';

class IncomeModel extends IncomeEntity {
  IncomeModel({
    required super.title,
    required super.amount,
    required super.date,
    super.tag,
    super.description,
    super.wallet,
  });

  // // Logic: Creating the model from JSON with all descriptors included
  factory IncomeModel.fromJson(Map<dynamic, dynamic> json) {
    return IncomeModel(
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: json['Date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      // Adding new descriptors to the factory
      tag: json['tag'],
      description: json['description'] ?? "",
      wallet: json["Wallet"],
    );
  }

  // // Logic: Converting the model back to JSON including tag and description
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'tag': tag,
      'description': description,
      "Wallet": wallet,
    };
  }
}
