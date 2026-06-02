// lib/features/savings_goals/domain/entities/saving_goal_entity.dart
// SavingGoalEntity: Core business model preserving synchronized identifier tracks and financial parameters across offline stores

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:uuid/uuid.dart';

class SavingGoalEntity {
  final String localId;
  int? goalId;
  int userId;
  String title;
  double targetAmount;
  double currentAmount;
  DateTime deadlineDate;
  RxBool isSynced;
  bool isDeleted;
  int currencyId;
  DateTime? createdAt;
  DateTime? updatedAt;

  SavingGoalEntity({
    String?
    localIdUid, // الحقل البرمجي المستلم للمعرف المحلي الفعلي لربط الكيانات
    RxBool? isSynced,
    this.goalId,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadlineDate,
    required this.currencyId,

    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  }) : isSynced = isSynced ?? false.obs,
       localId = localIdUid ?? const Uuid().v4();
}
