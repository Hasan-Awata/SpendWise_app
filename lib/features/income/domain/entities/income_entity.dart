import 'package:hive/hive.dart';

@HiveType(typeId: 1) // // Unique ID for this class in Hive
class IncomeEntity extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final int currencyId;

  @HiveField(4)
  final bool isFixed;

  @HiveField(5)
  final bool isMonthly;

  @HiveField(6)
  final int? days;

  @HiveField(7)
  final DateTime lastTime;

  @HiveField(8)
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
