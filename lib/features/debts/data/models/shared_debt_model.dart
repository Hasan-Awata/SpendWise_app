import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/features/debts/domain/entities/shared_debt_entity.dart';
import 'package:spendwise/features/sync/model/syncable_model.dart';
import 'package:uuid/uuid.dart';

part 'shared_debt_model.g.dart';

@collection
class SharedDebtModel implements SyncableModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String localId;

  @Index()
  int? debtId;

  int creditorId;
  int debtorId;

  double amount;

  String title;
  String status;

  DateTime createdAt;
  DateTime dueDate;

  int? creditorWalletId;
  int? debtorWalletId;

  double paidAmount;

  @override
  bool isSynced;

  @override
  bool isDeleted;

  @override
  int syncAttempts;

  @override
  DateTime? lastSyncError;

  DateTime? updatedAt;

  SharedDebtModel({
    required this.localId,
    this.debtId,
    required this.creditorId,
    required this.debtorId,
    required this.amount,
    required this.title,
    this.status = 'Pending',
    required this.createdAt,
    required this.dueDate,
    required this.creditorWalletId,
    required this.debtorWalletId,
    this.paidAmount = 0,
    this.isSynced = false,
    this.isDeleted = false,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  // ========================= ENTITY =========================

  SharedDebtEntity toEntity() {
    return SharedDebtEntity(
      localId: localId,
      debtId: debtId,
      creditorId: creditorId,
      debtorId: debtorId,
      amount: amount,
      title: title,
      status: status,
      createdAt: createdAt,
      dueDate: dueDate,
      creditorWalletId: creditorWalletId,
      debtorWalletId: debtorWalletId,
      paidAmount: paidAmount,
      isSynced: isSynced.obs,
      isDeleted: isDeleted,
      updatedAt: updatedAt,
    );
  }

  factory SharedDebtModel.fromEntity(SharedDebtEntity entity) {
    return SharedDebtModel(
      localId: entity.localId,
      debtId: entity.debtId,
      creditorId: entity.creditorId,
      debtorId: entity.debtorId,
      amount: entity.amount,
      title: entity.title,
      status: entity.status,
      createdAt: entity.createdAt,
      dueDate: entity.dueDate,
      creditorWalletId: entity.creditorWalletId,
      debtorWalletId: entity.debtorWalletId,
      paidAmount: entity.paidAmount,
      isSynced: entity.isSynced!.value,
      isDeleted: entity.isDeleted,
      updatedAt: entity.updatedAt,
    );
  }

  // ========================= JSON =========================

  factory SharedDebtModel.fromJson(
    Map<String, dynamic> json, {
    String? localId,
  }) {
    return SharedDebtModel(
      localId: localId ?? const Uuid().v4(),
      debtId: json['debtID'] ?? json['DebtID'],
      creditorId: json['creditorID'] ?? json['CreditorID'] ?? 0,
      debtorId: json['debtorID'] ?? json['DebtorID'] ?? 0,
      amount: (json['amount'] ?? json['Amount'] ?? 0).toDouble(),
      title: json['title'] ?? json['Title'] ?? '',
      status: json['status'] ?? json['Status'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      creditorWalletId:
          json['creditorWalletID'] ?? json['CreditorWalletID'] ?? 0,
      debtorWalletId: json['debtorWalletID'] ?? json['DebtorWalletID'] ?? 0,
      paidAmount: (json['paidAmount'] ?? json['PaidAmount'] ?? 0).toDouble(),
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      'creditorID': creditorId,
      'debtorID': debtorId,
      'amount': amount,
      'title': title,
      'status': status,
      'dueDate': dueDate.toUtc().toIso8601String(),
      'creditorWalletID': creditorWalletId ?? 0,
      'debtorWalletID': debtorWalletId ?? 0,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'PaidAmount': paidAmount,
    };
  }

  // ========================= SYNC =========================

  @override
  void markSynced(int id) {
    debtId = id;
    isSynced = true;
    isDeleted = false;
    syncAttempts = 0;
    lastSyncError = null;
    updatedAt = DateTime.now();
  }

  @override
  int? get serverId {
    if (debtId == null || debtId! <= 0) return null;
    return debtId;
  }

  @override
  String toString() {
    return '''
SharedDebtModel(
  debtId: $debtId,
  localId: $localId,
  creditorId: $creditorId,
  debtorId: $debtorId,
  amount: $amount,
  title: $title,
  status: $status,
  createdAt: $createdAt,
  dueDate: $dueDate,
  creditorWalletId: $creditorWalletId,
  debtorWalletId: $debtorWalletId,
  paidAmount: $paidAmount,
  isSynced: $isSynced,
  isDeleted: $isDeleted,
  syncAttempts: $syncAttempts,
  lastSyncError: $lastSyncError,
)
''';
  }
}
