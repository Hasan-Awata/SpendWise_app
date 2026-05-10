import 'package:isar/isar.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';
import 'package:uuid/uuid.dart';

part 'saving_goal_model.g.dart';

@collection
class SavingGoalModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String localId;
  @Index()
  int? goalId;
  int userId;

  String title;
  double targetAmount;
  double currentAmount;

  DateTime deadlineDate;

  bool isSynced;
  bool isDeleted;

  int syncAttempts;
  DateTime? lastSyncError;

  DateTime? createdAt;
  DateTime? updatedAt;
  SavingGoalModel({
    required this.localId,
    this.goalId,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadlineDate,
    this.isSynced = false,
    this.isDeleted = false,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // ========================= MAPPERS =========================

  factory SavingGoalModel.fromEntity(SavingGoalEntity entity) {
    return SavingGoalModel(
      localId: entity.localId,
      goalId: entity.goalId,
      userId: entity.userId,
      title: entity.title,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadlineDate: entity.deadlineDate,
      isSynced: entity.isSynced,
    );
  }

  SavingGoalEntity toEntity() {
    return SavingGoalEntity(
      goalId: goalId,
      userId: userId,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadlineDate: deadlineDate,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ========================= JSON =========================

  factory SavingGoalModel.fromJson(
    Map<String, dynamic> json, {
    String? localId,
  }) {
    return SavingGoalModel(
      localId: localId ?? const Uuid().v4(),
      goalId: json['goalID'] ?? json['goalId'],
      userId: json['userID'] ?? json['userId'] ?? -1,
      title: json['title'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      deadlineDate: json['deadlineDate'] != null
          ? DateTime.parse(json['deadlineDate'])
          : DateTime.now(),
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      if (!isCreate) 'goalID': goalId,
      'userID': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadlineDate': deadlineDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SavingGoalModel(title: $title, progress: $currentAmount/$targetAmount)';
  }
}
