// lib/features/transaction/data/models/transaction_model.dart
// TransactionModel: Isar collection mapping database entity fields directly into .NET core backend structures

import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/features/category/data/models/category_model.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/transaction_entity.dart';

part 'transaction_model.g.dart';

enum enTransactionType {
  addition, // يمثل القيمة 0 (الدخل / الإيداع)
  dedduction, // يمثل القيمة 1 (المصاريف / السحب)
}

@collection
class TransactionModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String localId;

  @Index()
  int? id;
  int? userId;
  String? title;
  double amount;
  double amountInSp;
  DateTime date;

  String? description;
  bool isSynced;
  bool isDeleted;

  int? walletId;
  String? walletLocalId;
  int? categoryId;
  int? expenseTagId;

  bool isIncomeProcess;
  bool isExpenseProcess;
  bool isFixedIncomeProcess;
  bool isFixedExpenseProcess;
  bool isSavingGoalProcess;
  bool isDebtProcess;

  @enumerated
  enTransactionType transactionType;

  int syncAttempts;
  DateTime? lastSyncError;

  DateTime? createdAt;
  DateTime? updatedAt;

  TransactionModel({
    required this.localId,
    this.id,
    this.userId,
    required this.title,
    required this.amount,
    this.amountInSp = 0.0,
    required this.date,
    this.description,
    this.isSynced = false,
    this.isDeleted = false,
    this.walletId,
    this.walletLocalId,
    this.categoryId,
    this.expenseTagId,

    this.isIncomeProcess = false,
    this.isExpenseProcess = false,
    this.isFixedIncomeProcess = false,
    this.isFixedExpenseProcess = false,
    this.isSavingGoalProcess = false,
    this.isDebtProcess = false,

    required this.transactionType,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // ========================= MAPPERS =========================

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    // تصحيح الخطأ هنا: تمرير القيمة للـ parameter مباشرة وليس عبر مساواة كـ instance member
    return TransactionModel(
      localId: entity.localId ?? const Uuid().v4(),
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      amount: entity.amount,
      amountInSp: 0.0,
      date: entity.date,
      description: entity.description,
      walletId: entity.walletId,
      walletLocalId: entity.walletLocalId,
      categoryId: entity.categoryId,
      expenseTagId: entity.expenseTagId,
      transactionType: entity.isExpense
          ? enTransactionType.dedduction
          : enTransactionType.addition,
      isSynced: entity.isSynced.value,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TransactionEntity toEntity({
    CategoryModel? category,
    TagEntity? tag,
    WalletEntity? wallet,
  }) {
    return TransactionEntity(
      localId: localId,
      isarId: isarId,
      id: id,
      userId: userId,
      title: title ?? "no title",
      amount: amount,
      date: date,
      description: description,
      walletId: walletId,
      walletLocalId: walletLocalId,
      categoryId: categoryId,
      expenseTagId: expenseTagId,
      isSynced: isSynced.obs,
      isDeleted: isDeleted,
      isExpense: transactionType == enTransactionType.dedduction,
      category: category,
      tag: tag,
      wallet: wallet,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ========================= JSON =========================
  factory TransactionModel.fromJson(
    Map<String, dynamic> json, {
    String? localId,
  }) {
    final dynamic rawValue =
        json['transactionType'] ?? json['TransactionType'] ?? 0;

    int rawType = 0;

    if (rawValue is int) {
      rawType = rawValue;
    } else if (rawValue is String) {
      final parsedInt = int.tryParse(rawValue);

      if (parsedInt != null) {
        rawType = parsedInt;
      } else {
        final stringValue = rawValue.toLowerCase();

        if (stringValue == 'dedduction' ||
            stringValue == 'expense' ||
            stringValue == '1') {
          rawType = 1;
        } else {
          rawType = 0;
        }
      }
    }

    final enTransactionType resolvedType = rawType == 1
        ? enTransactionType.dedduction
        : enTransactionType.addition;

    bool checkProcessId(dynamic idValue) {
      if (idValue == null) return false;

      if (idValue is int) {
        return idValue != -1;
      }

      if (idValue is String) {
        final parsed = int.tryParse(idValue);
        return parsed != null && parsed != -1;
      }

      return false;
    }

    final int? transactionId = json['transactionId'] ?? json['TransactionId'];

    return TransactionModel(
      localId: const Uuid().v4(),

      id: transactionId,

      userId: json['userId'] ?? json['UserId'],

      title: json['title'] ?? json['Title'] ?? '',

      amount: (json['amount'] ?? json['Amount'] ?? 0).toDouble(),

      amountInSp: (json['amountInSp'] ?? json['AmountInSp'] ?? 0).toDouble(),

      date: _parseDate(json),

      description: json['description'] ?? json['Description'] ?? '',

      walletId: json['walletId'] ?? json['WalletId'],

      walletLocalId: json['walletLocalId'] ?? json['WalletLocalId'],

      categoryId: json['categoryId'] ?? json['CategoryId'],

      expenseTagId:
          json['tagId'] ??
          json['TagId'] ??
          json['expenseTagId'] ??
          json['ExpenseTagId'],

      isIncomeProcess: checkProcessId(json['incomeId'] ?? json['IncomeId']),

      isExpenseProcess: checkProcessId(json['expenseId'] ?? json['ExpenseId']),

      isFixedIncomeProcess: checkProcessId(
        json['fixedIncomeId'] ?? json['FixedIncomeId'],
      ),

      isFixedExpenseProcess: checkProcessId(
        json['fixedExpenseId'] ?? json['FixedExpenseId'],
      ),

      isSavingGoalProcess: checkProcessId(
        json['savingGoalId'] ?? json['SavingGoalId'],
      ),

      isDebtProcess: checkProcessId(json['debtId'] ?? json['DebtId']),

      transactionType: resolvedType,

      isSynced: true,
      isDeleted: false,

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      'transactionId': id ?? -1,
      'userId': userId,
      'title': (title == null || title!.isEmpty) ? "no title" : title,
      'amount': amount,
      'amountInSp': amountInSp,
      'date': date.toUtc().toIso8601String(),
      'description': description ?? "no description",
      'walletId': walletId,
      'walletLocalId': walletLocalId,
      'categoryId': categoryId,
      'expenseTagId': expenseTagId,
      'transactionType': transactionType.index,

      'incomeId': isIncomeProcess ? 0 : -1,
      'expenseId': isExpenseProcess ? 0 : -1,
      'fixedIncomeId': isFixedIncomeProcess ? 0 : -1,
      'fixedExpenseId': isFixedExpenseProcess ? 0 : -1,
      'savingGoalId': isSavingGoalProcess ? 0 : -1,
      'debtId': isDebtProcess ? 0 : -1,
    };
  }

  static DateTime _parseDate(Map<String, dynamic> json) {
    final value = json['date'] ?? json['Date'];
    if (value == null) {
      return DateTime.now();
    }
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
