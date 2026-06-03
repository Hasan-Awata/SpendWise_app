import 'package:isar/isar.dart';
import 'package:spendwise/features/sync/model/syncable_model.dart';

part 'fixedIncome_model.g.dart';

@collection
class FixedIncomeModel implements SyncableModel {
  Id isarId = Isar.autoIncrement;

  @Index()
  int fixedIncomeId;

  int userId;
  int tagId; // مضاف حديثاً بناءً على الـ DTO
  String title;
  double amount;
  bool isMonthly; // مضاف حديثاً
  bool isActive;
  int days; // مضاف حديثاً
  DateTime lastTime; // مضاف حديثاً

  @override
  bool isDeleted;

  @override
  bool isSynced;

  @override
  int syncAttempts;

  FixedIncomeModel({
    this.fixedIncomeId = -1,
    required this.userId,
    required this.tagId,
    required this.title,
    required this.amount,
    required this.isMonthly,
    required this.isActive,
    required this.days,
    required this.lastTime,
    this.isDeleted = false,
    this.isSynced = false,
    this.syncAttempts = 0,
  });

  factory FixedIncomeModel.fromJson(Map<String, dynamic> json) {
    return FixedIncomeModel(
      fixedIncomeId: json['fixedIncomeId'] ?? -1,
      userId: json['userId'] ?? -1,
      tagId: json['tagId'] ?? -1,
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      isMonthly: json['isMonthly'] ?? true,
      isActive: json['isActive'] ?? true,
      days: json['days'] ?? 1,
      lastTime: DateTime.parse(json['lastTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fixedIncomeId': fixedIncomeId,
      'userId': userId,
      'tagId': tagId,
      'title': title,
      'amount': amount,
      'isMonthly': isMonthly,
      'isActive': isActive,
      'days': days,
      'lastTime': lastTime.toIso8601String(),
    };
  }

  @override
  void markSynced(int id) {
    fixedIncomeId = id;
    isSynced = true;
    isDeleted = false;
    syncAttempts = 0;
  }

  @override
  int? get serverId {
    if (fixedIncomeId <= 0) return null;
    return fixedIncomeId;
  }
}
