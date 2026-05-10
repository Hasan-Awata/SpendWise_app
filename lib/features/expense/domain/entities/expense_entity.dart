import 'package:spendwise/features/category/data/model/category_model.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart' show Uuid;

class ExpenseEntity {
  final String localId;
  final int? id;
  final int? userId;
  String title;
  double amount;
  final DateTime date;

  final String? description;
  final String? products;

  bool isSynced;
  bool isDeleted;

  int? walletId;
  int? categoryId;
  int? expenseTagId;

  final bool? isFixed;

  CategoryModel? category;
  TagEntity? tag;
  WalletEntity? wallet;

  DateTime? createdAt;
  DateTime? updatedAt;
  ExpenseEntity({
    String? localId,
    this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.date,
    this.description,
    this.products,
    this.isSynced = false,
    this.isDeleted = false,
    this.walletId,
    this.categoryId,
    this.expenseTagId,
    this.isFixed = false,
    this.category,
    this.tag,
    this.wallet,
    this.createdAt,
    this.updatedAt,
  }) : localId = localId ?? const Uuid().v4();
}
