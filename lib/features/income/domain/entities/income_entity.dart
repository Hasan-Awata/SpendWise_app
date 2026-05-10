import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

class IncomeEntity {
  String localId;
  int? id;
  int userId;
  String title;
  int? walletId;
  double amount;
  DateTime date;
  int? incomeTagId;
  String? description;

  bool isSynced;
  bool isDeleted;

  TagEntity? tag;
  WalletEntity? wallet;

  DateTime? createdAt;
  DateTime? updatedAt;

  IncomeEntity({
    String? localId,
    this.id,
    required this.userId,
    required this.title,
    this.walletId,
    required this.amount,
    required this.date,
    this.incomeTagId,
    this.description,
    this.isSynced = false,
    this.isDeleted = false,
    this.tag,
    this.wallet,
    this.createdAt,
    this.updatedAt,
  }) : localId = localId ?? const Uuid().v4();
}
