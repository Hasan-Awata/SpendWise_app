import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:uuid/uuid.dart';

class CategoryBudgetEntity {
  String localId;

  int? categoryBudgetId;
  int userId;

  int categoryId;

  double percentageLimit;
  double percentageProgress;

  double moneyLimit;
  double spendingProgress;

  DateTime startDate;
  DateTime endDate;

  bool isActive;

  RxBool isSynced;
  bool isDeleted;

  DateTime? createdAt;
  DateTime? updatedAt;

  CategoryBudgetEntity({
    String? localId,
    RxBool? isSynced,
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
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  }) : localId = localId ?? const Uuid().v4(),
       isSynced = isSynced ?? false.obs;

  CategoryBudgetEntity copyWith({
    int? categoryBudgetId,
    int? userId,
    int? categoryId,
    double? percentageLimit,
    double? percentageProgress,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return CategoryBudgetEntity(
      categoryBudgetId: categoryBudgetId ?? this.categoryBudgetId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      percentageLimit: percentageLimit ?? this.percentageLimit,
      percentageProgress: percentageProgress ?? this.percentageProgress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
