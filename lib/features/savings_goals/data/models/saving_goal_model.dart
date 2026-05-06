// // [تنبيه: تم تحديث الموديل ليدعم التخزين المحلي والمزامنة بنفس نمط WalletModel]

import 'package:uuid/uuid.dart';

class SavingGoalModel {
  int? goalId; // المعرف القادم من السيرفر
  String? localId; // المعرف المحلي (UUID)
  int userId;
  String title;
  double targetAmount;
  double currentAmount;
  DateTime deadlineDate;
  bool isSynced;

  SavingGoalModel({
    String? localId,
    this.goalId,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadlineDate,
    this.isSynced = false,
  }) : localId = localId ?? const Uuid().v4();

  // // المصنع الخاص بالبيانات القادمة من السيرفر (API)
  factory SavingGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingGoalModel(
      localId: const Uuid()
          .v4(), // توليد معرف محلي جديد عند الجلب من السيرفر لأول مرة
      goalId: json['goalID'] ?? json['goalId'],
      userId: (json['userID'] ?? json['userId'] ?? -1) as int,
      title: json['title'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0.0).toDouble(),
      deadlineDate: json['deadlineDate'] != null
          ? DateTime.parse(json['deadlineDate'])
          : DateTime.now(),
      isSynced: true,
    );
  }

  // // تحويل البيانات لإرسالها إلى السيرفر (API)
  Map<String, dynamic> toJson() {
    return {
      'goalID': goalId == -1 ? null : goalId,
      'userID': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadlineDate': deadlineDate.toIso8601String(),
    };
  }

  // // المصنع الخاص بالبيانات القادمة من التخزين المحلي (Hive)
  factory SavingGoalModel.fromLocal(Map<dynamic, dynamic> map) {
    return SavingGoalModel(
      localId: map['localId'],
      goalId: (map['goalId'] ?? map['goalID'] ?? -1) as int,
      userId: (map['userId'] ?? map['userID'] ?? -1) as int,
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      deadlineDate: map['deadlineDate'] != null
          ? DateTime.parse(map['deadlineDate'])
          : DateTime.now(),
      isSynced: map['isSynced'] == true || map['isSynced'] == 1,
    );
  }

  // // تحويل البيانات لحفظها في التخزين المحلي (Hive)
  Map<dynamic, dynamic> toLocal() {
    return {
      'goalId': goalId ?? -1,
      'localId': localId,
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadlineDate': deadlineDate.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  @override
  String toString() {
    return '''SavingGoalModel(
      localId: $localId, 
      goalId: $goalId, 
      userId: $userId, 
      title: $title, 
      targetAmount: $targetAmount, 
      currentAmount: $currentAmount,
      isSynced: $isSynced
    )''';
  }
}
