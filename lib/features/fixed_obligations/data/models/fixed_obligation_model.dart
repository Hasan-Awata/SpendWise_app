import 'package:isar/isar.dart';
import 'package:spendwise/features/sync/model/syncable_model.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

part 'fixed_obligation_model.g.dart';

@collection
class FixedObligationModel implements SyncableModel {
  Id isarId = Isar.autoIncrement; // معرف خاص بـ Isar للتخزين المحلي

  @Index()
  int id;

  int walletId;
  int ownerId;
  String title;
  double amount;
  DateTime lastTime;
  bool isActive;

  int days;
  @ignore
  WalletEntity? wallet;

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
    required this.walletId,
    this.wallet,
    required this.amount,
    required this.lastTime,
    required this.isActive,
    this.isDeleted = false,
    required this.days,
    this.isSynced = false,
    this.syncAttempts = 0,
  });

  factory FixedObligationModel.fromJson(Map<String, dynamic> json) {
    return FixedObligationModel(
      id: json['fixedObligationId'] ?? -1,
      ownerId: json['ownerId'] ?? -1,
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      lastTime: DateTime.parse(json['lastTime']),
      days: json['days'],
      isActive: json['isActive'] ?? false,
      walletId: json['walletId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'title': title,
      'walletId': walletId,
      'amount': amount,
      'days': days,
      'lastTime': lastTime.toIso8601String(),
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
