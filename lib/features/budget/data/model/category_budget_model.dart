import 'package:get/get.dart'; // تأكد من بقاء الاستيراد من أجل تحويلات الـ Entity
import 'package:isar/isar.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';
import 'package:uuid/uuid.dart';

part 'category_budget_model.g.dart';

@collection
class CategoryBudgetModel {
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

  double moneyLimit;
  double spendingProgress;

  DateTime startDate;
  DateTime endDate;

  bool isActive;

  bool isSynced;
  bool isDeleted;

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
    this.moneyLimit = 0,
    this.spendingProgress = 0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.isSynced = false, // القيمة الافتراضية أصبحت bool عادية
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
      moneyLimit: moneyLimit,
      spendingProgress: spendingProgress,
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
      moneyLimit: entity.moneyLimit,
      spendingProgress: entity.spendingProgress,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      isSynced: entity
          .isSynced
          .value, // استخراج القيمة الحقيقية للـ bool من الـ RxBool
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
    // معالجة مرنة لجلب النصوص البرمجية للتواريخ بحالتين الأحرف الكبيرة والصغيرة
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

      moneyLimit: (json['moneyLimit'] ?? json['MoneyLimit'] ?? 0).toDouble(),

      spendingProgress:
          (json['spendingProgress'] ?? json['SpendingProgress'] ?? 0)
              .toDouble(),

      startDate: startDateRaw != null
          ? DateTime.parse(startDateRaw)
          : DateTime.now(),

      endDate: endDateRaw != null ? DateTime.parse(endDateRaw) : DateTime.now(),

      isActive: json['isActive'] ?? json['IsActive'] ?? true,

      isSynced: true, // متوافق تماماً الآن كقيمة bool
    );
  }

  Map<String, dynamic> toJson() {
    // تم تفصيل الـ Map لتطابق كلاس CategoryBudgetDTO في الـ .NET تماماً
    return {
      'categoryBudgetId': -1,
      'userId': userId,
      'categoryId': categoryId,
      'percentageLimit': percentageLimit, // سيرسل كـ double متوافق مع decimal
      // 'percentageProgress': percentageProgress,
      'startDate': startDate.toIso8601String(), // صيغة النص القياسية للتاريخ
      'endDate': endDate.toIso8601String(), // صيغة النص القياسية للتاريخ
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'CategoryBudgetModel(isarId: $isarId, localId: $localId, categoryBudgetId: $categoryBudgetId, userId: $userId, categoryId: $categoryId, percentageLimit: $percentageLimit%, percentageProgress: $percentageProgress, moneyLimit: $moneyLimit, spendingProgress: $spendingProgress, startDate: $startDate, endDate: $endDate, isActive: $isActive, isSynced: $isSynced, isDeleted: $isDeleted)';
  }
}
