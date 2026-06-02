import 'package:get/state_manager.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';
import 'package:spendwise/features/sync/model/syncable_model.dart';
import 'package:uuid/uuid.dart';

part 'saving_goal_model.g.dart';

@collection
class SavingGoalModel implements SyncableModel {
  Id isarId = Isar.autoIncrement;

  @override
  int? get serverId {
    if (goalId == null || goalId! <= 0) return null;
    return goalId;
  }

  @Index(unique: true)
  String localId;

  @Index()
  int? goalId;

  int userId;

  String title;

  double targetAmount;

  double currentAmount;

  DateTime deadlineDate;

  int currencyId;

  // =====================================================
  // SYNC
  // =====================================================

  @override
  bool isSynced;

  @override
  bool isDeleted;

  @override
  int syncAttempts;

  @override
  DateTime? lastSyncError;

  // =====================================================
  // TIMESTAMPS
  // =====================================================

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
    required this.currencyId,
    this.isSynced = false,
    this.isDeleted = false,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // =====================================================
  // FACTORY CREATE
  // =====================================================

  factory SavingGoalModel.create({
    int? goalId,
    required int userId,
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime deadlineDate,
    required int currencyId,
    String? localId,
    bool isSynced = false,
    bool isDeleted = false,
  }) {
    return SavingGoalModel(
      localId: localId ?? const Uuid().v4(),
      goalId: goalId,
      userId: userId,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadlineDate: deadlineDate,
      currencyId: currencyId,
      isSynced: isSynced,
      isDeleted: isDeleted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // =====================================================
  // ENTITY MAPPERS
  // =====================================================

  factory SavingGoalModel.fromEntity(SavingGoalEntity entity) {
    return SavingGoalModel(
      localId: entity.localId,
      goalId: entity.goalId,
      userId: entity.userId,
      title: entity.title,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadlineDate: entity.deadlineDate,
      currencyId: entity.currencyId,
      isSynced: entity.isSynced.value,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SavingGoalEntity toEntity() {
    return SavingGoalEntity(
      localIdUid: localId,
      goalId: goalId,
      userId: userId,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadlineDate: deadlineDate,
      currencyId: currencyId,
      isSynced: isSynced.obs,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // =====================================================
  // JSON
  // =====================================================

  factory SavingGoalModel.fromJson(
    Map<String, dynamic> json, {
    String? localId,
  }) {
    return SavingGoalModel(
      localId: localId ?? const Uuid().v4(),

      goalId: int.tryParse(
        (json['GoalID'] ?? json['goalID'] ?? json['goalId'] ?? json['id'] ?? '')
            .toString(),
      ),

      userId:
          int.tryParse(
            (json['UserID'] ?? json['userID'] ?? json['userId'] ?? 0)
                .toString(),
          ) ??
          0,

      title: (json['Title'] ?? json['title'] ?? '').toString(),

      targetAmount:
          double.tryParse(
            (json['TargetAmount'] ?? json['targetAmount'] ?? 0).toString(),
          ) ??
          0.0,

      currentAmount:
          double.tryParse(
            (json['CurrentAmount'] ?? json['currentAmount'] ?? 0).toString(),
          ) ??
          0.0,

      deadlineDate: json['DeadlineDate'] != null
          ? DateTime.parse(json['DeadlineDate'].toString())
          : json['deadlineDate'] != null
          ? DateTime.parse(json['deadlineDate'].toString())
          : DateTime.now(),

      currencyId:
          int.tryParse(
            (json['CurrencyId'] ?? json['currencyId'] ?? 1).toString(),
          ) ??
          1,

      isSynced: true,

      isDeleted: json['isDeleted'] ?? json['IsDeleted'] ?? false,

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      'goalId': goalId ?? -1,
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadlineDate': deadlineDate.toIso8601String(),
      'currencyId': currencyId,
      'isActive': true,
    };
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  SavingGoalModel copyWith({
    Id? isarId,
    String? localId,
    int? goalId,
    int? userId,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadlineDate,
    int? currencyId,
    bool? isSynced,
    bool? isDeleted,
    int? syncAttempts,
    DateTime? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingGoalModel(
      localId: localId ?? this.localId,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      currencyId: currencyId ?? this.currencyId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    )..isarId = isarId ?? this.isarId;
  }

  // =====================================================
  // SYNC HELPERS
  // =====================================================

  @override
  void markSynced(int id) {
    goalId = id;
    isSynced = true;
    isDeleted = false;
    syncAttempts = 0;
    lastSyncError = null;
    updatedAt = DateTime.now();
  }

  // =====================================================
  // DEBUG
  // =====================================================

  @override
  String toString() {
    return '''
SavingGoalModel(
  isarId: $isarId,
  localId: $localId,
  goalId: $goalId,
  userId: $userId,
  title: $title,
  targetAmount: $targetAmount,
  currentAmount: $currentAmount,
  deadlineDate: $deadlineDate,
  currencyId: $currencyId,
  isSynced: $isSynced,
  isDeleted: $isDeleted,
  syncAttempts: $syncAttempts,
  lastSyncError: $lastSyncError,
  createdAt: $createdAt,
  updatedAt: $updatedAt
)
''';
  }
}
