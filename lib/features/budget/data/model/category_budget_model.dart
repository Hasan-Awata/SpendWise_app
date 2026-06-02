import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';
import 'package:spendwise/features/sync/model/syncable_model.dart';
import 'package:uuid/uuid.dart';

part 'category_budget_model.g.dart';

@collection
class CategoryBudgetModel implements SyncableModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String localId;

  @Index()
  int? categoryBudgetId;

  int userId;

  @Index()
  int categoryId;

  double percentageLimit;
  double percentageProgress;

  // الخصائص المضافة لتتطابق مع الـ DTO في الـ Backend
  double moneyLimit;
  double spendingProgress;

  DateTime startDate;
  DateTime endDate;

  bool isActive;

  @override
  bool isSynced;
  @override
  bool isDeleted;

  @override
  int syncAttempts;
  DateTime? lastSyncError;

  DateTime? createdAt;
  DateTime? updatedAt;

  CategoryBudgetModel({
    required this.localId,
    this.categoryBudgetId,
    required this.userId,
    required this.categoryId,
    required this.percentageLimit,
    this.percentageProgress = 0,
    required this.moneyLimit, // تم الإضافة
    required this.spendingProgress, // تم الإضافة
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.isSynced = false,
    this.isDeleted = false,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // ================= ENTITY =================

  CategoryBudgetEntity toEntity() {
    return CategoryBudgetEntity(
      localId: localId,
      categoryBudgetId: categoryBudgetId,
      userId: userId,
      categoryId: categoryId,
      percentageLimit: percentageLimit,
      percentageProgress: percentageProgress,
      moneyLimit: moneyLimit, // تم الإضافة
      spendingProgress: spendingProgress, // تم الإضافة
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      isSynced: isSynced.obs,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CategoryBudgetModel.fromEntity(CategoryBudgetEntity entity) {
    return CategoryBudgetModel(
      localId: entity.localId,
      categoryBudgetId: entity.categoryBudgetId,
      userId: entity.userId,
      categoryId: entity.categoryId,
      percentageLimit: entity.percentageLimit,
      percentageProgress: entity.percentageProgress,
      moneyLimit: entity.moneyLimit, // تم الإضافة
      spendingProgress: entity.spendingProgress, // تم الإضافة
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      isSynced: entity.isSynced.value,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // ================= JSON =================

  factory CategoryBudgetModel.fromJson(
    Map<String, dynamic> json, {
    String? localId,
  }) {
    final startDateRaw = json['startDate'] ?? json['StartDate'];
    final endDateRaw = json['endDate'] ?? json['EndDate'];

    return CategoryBudgetModel(
      localId: localId ?? const Uuid().v4(),
      categoryBudgetId: json['categoryBudgetId'] ?? json['CategoryBudgetId'],
      userId: json['userId'] ?? json['UserId'] ?? 0,
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? 0,
      percentageLimit: (json['percentageLimit'] ?? json['PercentageLimit'] ?? 0)
          .toDouble(),
      percentageProgress:
          (json['percentageProgress'] ?? json['PercentageProgress'] ?? 0)
              .toDouble(),
      // جلب البيانات من الـ JSON
      moneyLimit: (json['moneyLimit'] ?? json['MoneyLimit'] ?? 0).toDouble(),
      spendingProgress:
          (json['spendingProgress'] ?? json['SpendingProgress'] ?? 0)
              .toDouble(),
      startDate: startDateRaw != null
          ? DateTime.parse(startDateRaw)
          : DateTime.now(),
      endDate: endDateRaw != null ? DateTime.parse(endDateRaw) : DateTime.now(),
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      isSynced: true,
    );
  }

  // ================= TO JSON =================

  Map<String, dynamic> toJson() {
    return {
      'categoryBudgetId': categoryBudgetId,
      'userId': userId,
      'categoryId': categoryId,
      'percentageLimit': percentageLimit,
      // 'percentageProgress': percentageProgress,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'CategoryBudgetModel(localId: $localId, categoryBudgetId: $categoryBudgetId, userId: $userId, categoryId: $categoryId, percentageLimit: $percentageLimit, moneyLimit: $moneyLimit, spendingProgress: $spendingProgress, startDate: $startDate, endDate: $endDate, isActive: $isActive, isSynced: $isSynced)';
  }

  @override
  void markSynced(int id) {
    categoryBudgetId = id;
    isSynced = true;
    isDeleted = false;
    syncAttempts = 0;
    lastSyncError = null;
    updatedAt = DateTime.now();
  }

  @override
  int? get serverId {
    if (categoryBudgetId == null || categoryBudgetId! <= 0) return null;
    return categoryBudgetId;
  }
}
