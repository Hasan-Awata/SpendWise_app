import 'package:isar/isar.dart';
import 'package:spendwise/features/category/data/model/category_model.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.g.dart';

@collection
class ExpenseModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String localId;
  @Index()
  int? id;
  int? userId;
  String? title;
  double amount;
  DateTime date;

  String? description;
  String? products;

  bool isSynced;
  bool isDeleted;

  int? walletId;
  int? categoryId;
  int? expenseTagId;

  bool? isFixed;

  int syncAttempts;
  DateTime? lastSyncError;

  // =====================================================
  // TIMESTAMPS
  // =====================================================

  DateTime? createdAt;
  DateTime? updatedAt;

  ExpenseModel({
    required this.localId,
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
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // ========================= MAPPERS =========================

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      localId: entity.localId,
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      description: entity.description,
      products: entity.products,
      walletId: entity.walletId,
      categoryId: entity.categoryId,
      expenseTagId: entity.expenseTagId,
      isSynced: entity.isSynced,
      isDeleted: entity.isDeleted,
      isFixed: entity.isFixed,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ExpenseEntity toEntity({
    CategoryModel? category,
    TagEntity? tag,
    WalletEntity? wallet,
  }) {
    return ExpenseEntity(
      localId: localId,
      id: id,
      userId: userId,
      title: title ?? "no title",
      amount: amount,
      date: date,
      description: description,
      products: products,
      walletId: walletId,
      categoryId: categoryId,
      expenseTagId: expenseTagId,
      isSynced: isSynced,
      isDeleted: isDeleted,
      isFixed: isFixed,
      category: category,
      tag: tag,
      wallet: wallet,
    );
  }

  // ========================= JSON =========================

  factory ExpenseModel.fromJson(Map<String, dynamic> json, {String? localId}) {
    return ExpenseModel(
      localId: localId ?? const Uuid().v4(),
      id: json['expenseId'] ?? json['ExpenseId'],
      userId: json['userId'] ?? json['UserId'],
      title: json['title'] ?? json['Title'] ?? '',
      amount: (json['amount'] ?? json['Amount'] ?? 0).toDouble(),
      date: _parseDate(json),
      description: json['description'] ?? json['Description'],
      products: json['products'] ?? json['Products'],
      walletId: json['walletId'] ?? json['WalletId'],
      categoryId: json['categoryId'] ?? json['CategoryId'],
      expenseTagId: json['expenseTagId'] ?? json['ExpenseTagId'],
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      'expenseId': id ?? -1,
      'userId': userId,
      'title': (title == null || title!.isEmpty) ? "no title" : title,
      'amount': amount,
      'date': date.toUtc().toIso8601String(),
      'description': description ?? "no description",
      'products': products ?? '',
      'walletId': walletId,
      'categoryId': categoryId,
      'expenseTagId': expenseTagId,
    };
  }

  static DateTime _parseDate(Map<String, dynamic> json) {
    final value = json['date'] ?? json['Date'];
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
