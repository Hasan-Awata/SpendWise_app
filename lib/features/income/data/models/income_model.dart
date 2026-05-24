import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

part 'income_model.g.dart';

@collection
class IncomeModel {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true)
  String localId;
  @Index()
  int? id;
  int userId;

  int? walletId;
  int? incomeTagId;

  String? title;
  double amount;
  DateTime date;

  String? description;

  int syncAttempts;
  DateTime? lastSyncError;
  String? walletLocalId;

  bool isSynced = false;
  bool isDeleted = false;

  DateTime? createdAt;
  DateTime? updatedAt;
  IncomeModel({
    this.walletLocalId,
    required this.localId,
    this.id,
    required this.userId,
    this.walletId,
    this.incomeTagId,
    required this.title,
    required this.amount,
    required this.date,
    this.description,
    this.isSynced = false,
    this.isDeleted = false,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // ========================= MAPPERS =========================

  /// Model → Entity
  IncomeEntity toEntity({TagEntity? tag, WalletEntity? wallet}) {
    return IncomeEntity(
      localId: localId,
      id: id,
      userId: userId,
      title: title ?? "no title",
      walletId: walletId!,
      amount: amount,
      date: date,
      incomeTagId: incomeTagId,
      description: description ?? "",
      walletLocalId: walletLocalId,
      isSynced: isSynced.obs,
      isDeleted: isDeleted,
      tag: tag,
      wallet: wallet,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Entity → Model
  factory IncomeModel.fromEntity(IncomeEntity entity) {
    return IncomeModel(
      localId: entity.localId,
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      walletId: entity.walletId,
      amount: entity.amount,
      date: entity.date,
      incomeTagId: entity.incomeTagId,
      description: entity.description,
      isSynced: entity.isSynced.value,
      isDeleted: entity.isDeleted,
      walletLocalId: entity.walletLocalId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // ========================= JSON =========================

  factory IncomeModel.fromJson(Map<String, dynamic> json, {String? localId}) {
    return IncomeModel(
      localId: localId ?? const Uuid().v4(),
      id: json['id'] ?? json['Id'],
      userId: json['userId'] ?? json['UserId'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      walletId: json['walletId'] ?? json['WalletId'],
      amount: (json['amount'] ?? json['Amount'] ?? 0).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      incomeTagId: json['incomeTagId'] ?? json['IncomeTagId'],
      description: json['description'] ?? json['Description'],
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      'id': id ?? -1,
      'userId': userId,
      'title': (title == null || title!.isEmpty) ? "no title" : title,
      'walletId': walletId,
      'amount': amount,
      'date': date.toUtc().toIso8601String(),
      'incomeTagId': incomeTagId ?? -1,
      'description': description ?? "no description",
    };
  }

  @override
  String toString() {
    return '''
IncomeModel {
  isarId: $isarId
  localId: $localId
  id: $id
  userId: $userId
  walletId: $walletId
  incomeTagId: $incomeTagId
  title: $title
  amount: $amount
  date: $date
  description: $description
  walletLocalId: $walletLocalId
  isSynced: $isSynced
  isDeleted: $isDeleted
  syncAttempts: $syncAttempts
  lastSyncError: $lastSyncError
  createdAt: $createdAt
  updatedAt: $updatedAt
}
''';
  }
}
