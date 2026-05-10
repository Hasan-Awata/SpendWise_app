import 'package:uuid/uuid.dart';

class SavingGoalEntity {
  final String localId;
  int? goalId;
  int userId;

  String title;
  double targetAmount;
  double currentAmount;
  DateTime deadlineDate;

  bool isSynced;
  bool isDeleted;

  DateTime? createdAt;
  DateTime? updatedAt;
  SavingGoalEntity({
    String? localIdUid,
    this.goalId,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadlineDate,
    this.isSynced = false,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  }) : localId = localIdUid ?? const Uuid().v4();
}
