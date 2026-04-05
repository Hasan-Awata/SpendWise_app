import 'package:hive/hive.dart';

class IncomeEntity extends HiveObject {
  final int id;

  final String title;

  final double amount;

  final int currencyId;

  final bool isFixed;

  final bool isMonthly;

  final int? days;

  final DateTime lastTime;

  final int userId;

  IncomeEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.isFixed,
    required this.isMonthly,
    this.days,
    required this.lastTime,
    required this.currencyId,
    required this.userId,
  });
}
