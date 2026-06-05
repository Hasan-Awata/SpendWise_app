import 'package:get/get.dart';

class SharedDebtEntity {
  String localId;

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

  RxBool? isSynced;

  bool isDeleted;

  int syncAttempts;

  DateTime? lastSyncError;

  DateTime? updatedAt;

  SharedDebtEntity({
    RxBool? isSynced,
    required this.localId,
    this.debtId,
    required this.creditorId,
    required this.debtorId,
    required this.amount,
    required this.title,
    this.status = 'Pending',
    required this.createdAt,
    required this.dueDate,
    this.creditorWalletId,
    this.debtorWalletId,
    this.paidAmount = 0,

    this.isDeleted = false,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? updatedAt,
  }) : isSynced = isSynced ?? false.obs,
       updatedAt = updatedAt ?? DateTime.now();
}
