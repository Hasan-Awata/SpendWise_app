import 'package:isar/isar.dart';
import 'package:spendwise/features/sync/model/syncable_model.dart';

part 'fixed_obligation_model.g.dart';

@collection
class FixedObligationModel implements SyncableModel {
  Id isarId = Isar.autoIncrement; // معرف خاص بـ Isar للتخزين المحلي

  @Index()
  int id;

  int ownerId;
  String title;
  double amount;
  DateTime dueDate;
  bool isActive;

  @override
  bool isDeleted;

  @override
  bool isSynced;

  @override
  int syncAttempts;

  FixedObligationModel({
    this.id = -1,
    required this.ownerId,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.isActive,
    this.isDeleted = false,
    this.isSynced = false,
    this.syncAttempts = 0,
  });

  factory FixedObligationModel.fromJson(Map<String, dynamic> json) {
    return FixedObligationModel(
      id: json['id'] ?? -1,
      ownerId: json['ownerId'] ?? -1,
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  void markSynced(int id) {
    this.id = id;
    isSynced = true;
    isDeleted = false;
    syncAttempts = 0;
  }

  @override
  int? get serverId {
    if (id <= 0) return null;
    return id;
  }
}
