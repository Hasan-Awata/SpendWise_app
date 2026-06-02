// lib/features/expense/data/models/expense_model.dart

import 'dart:convert';

import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/features/category/data/models/category_model.dart';
import 'package:spendwise/features/expense/data/models/product_model.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/sync/model/syncable_model.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.g.dart';

@collection
class ExpenseModel implements SyncableModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String localId;

  @Index()
  int? id;

  int? userId;
  String? title;
  double amount;

  // الحقول الجديدة لتتبع توزيع الخصم
  double amountFromRegular;
  double amountFromSavings;

  DateTime date;
  String? description;
  List<ProductModel>? products;

  @override
  bool isSynced;
  @override
  bool isDeleted;

  int? walletId;

  String? walletLocalId;
  int? categoryId;
  int? expenseTagId;

  bool? isFixed;
  @override
  int syncAttempts;
  DateTime? lastSyncError;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isOverLimit;

  ExpenseModel({
    required this.localId,
    this.id,
    this.userId,
    this.title,
    required this.amount,
    this.amountFromRegular = 0.0,
    this.amountFromSavings = 0.0,
    required this.date,
    this.description,
    this.products,
    this.isSynced = false,
    this.isDeleted = false,
    this.walletId,

    this.walletLocalId,
    this.categoryId,
    this.expenseTagId,
    this.isFixed = false,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isOverLimit,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // =====================================================
  // ENTITY
  // =====================================================

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      localId: entity.localId,
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      amount: entity.amount,
      amountFromRegular: entity.amountFromRegular,
      amountFromSavings: entity.amountFromSavings,
      date: entity.date,
      description: entity.description,
      products: entity.products ?? [],
      walletId: entity.walletId,
      categoryId: entity.categoryId,

      expenseTagId: entity.expenseTagId,
      isSynced: entity.isSynced.value,
      isDeleted: entity.isDeleted,
      isFixed: entity.isFixed,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      walletLocalId: entity.walletLocalId,
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
      amountFromRegular: amountFromRegular,

      amountFromSavings: amountFromSavings,
      date: date,
      description: description,
      products: products,

      walletId: walletId,
      categoryId: categoryId,
      expenseTagId: expenseTagId,
      isSynced: isSynced.obs,
      isDeleted: isDeleted,
      isFixed: isFixed,
      category: category,
      tag: tag,
      wallet: wallet,
      walletLocalId: walletLocalId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isOverLimit: isOverLimit,
    );
  }

  // =====================================================
  // JSON
  // =====================================================

  factory ExpenseModel.fromJson(Map<String, dynamic> json, {String? localId}) {
    return ExpenseModel(
      localId: localId ?? const Uuid().v4(),
      id: json['expenseId'] ?? json['ExpenseId'],
      userId: json['userId'] ?? json['UserId'],
      title: json['title'] ?? json['Title'] ?? '',
      amount: (json['amount'] ?? json['Amount'] ?? 0).toDouble(),
      amountFromRegular: (json['amountFromRegular'] ?? 0).toDouble(),
      amountFromSavings: (json['amountFromSavings'] ?? 0).toDouble(),
      date: _parseDate(json),
      description: json['description'] ?? json['Description'],
      products: _parseProducts(json['products'] ?? json['Products']),
      walletId: json['walletId'] ?? json['WalletId'],
      categoryId: json['categoryId'] ?? json['CategoryId'],
      expenseTagId: json['expenseTagId'] ?? json['ExpenseTagId'],

      isSynced: true,
      isOverLimit: json['isOverLimit'] ?? false,
    );
  }

  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      "expenseId": id ?? -1,
      "userId": userId,
      "title": title ?? "no title",
      "walletId": walletId,

      "categoryId": categoryId,
      "amount": amount,
      "date": date.toUtc().toIso8601String(),
      "expenseTagId": expenseTagId ?? -1,
      "description": description ?? "",
      "products": products?.map((e) => e.toJson()).toList() ?? [],
    };
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static List<ProductModel>? _parseProducts(dynamic productsRaw) {
    if (productsRaw == null) return [];
    try {
      dynamic parsedList = (productsRaw is String)
          ? jsonDecode(productsRaw)
          : productsRaw;
      if (parsedList is List) {
        return parsedList
            .map(
              (jsonItem) =>
                  ProductModel.fromJson(jsonItem as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      print("Error parsing products: $e");
    }
    return [];
  }

  static DateTime _parseDate(Map<String, dynamic> json) {
    final value = json['date'] ?? json['Date'];
    return value != null
        ? (DateTime.tryParse(value.toString()) ?? DateTime.now())
        : DateTime.now();
  }

  @override
  void markSynced(int id) {
    this.id = id;
    isSynced = true;
    isDeleted = false;
    syncAttempts = 0;
    lastSyncError = null;
    updatedAt = DateTime.now();
  }

  @override
  int? get serverId {
    if (id == null || id! <= 0) return null;
    return id;
  }
}
