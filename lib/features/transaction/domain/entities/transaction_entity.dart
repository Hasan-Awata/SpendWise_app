// lib/features/transaction/domain/entities/transaction_entity.dart
// TransactionEntity: Domain entity representing a transaction node with real-time reactive sync state and process tracking flags

import 'package:get/get.dart';
import 'package:spendwise/features/category/data/models/category_model.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class TransactionEntity {
  final String? localId;
  final int? id;
  final int? userId;
  final String title;
  final double amount;

  // القيمة بالعملة المحلية المضافة حديثاً لتتوافق مع الـ Model والـ DTO
  final double amountInSp;

  final DateTime date;
  final String? description;

  // Reactive RxBool for real-time atomic UI synchronization status updates via GetX
  final RxBool isSynced;
  final bool isDeleted;

  final int? walletId;
  final String? walletLocalId;
  final int? categoryId;
  final int? expenseTagId;

  final bool
  isExpense; // True = Deduction (1), False = Addition (0) mapped to backend context
  final String currency;

  // الأعلام المنطقية (Flags) الجديدة لمتابعة نوع العملية (Process) المشتقة من الـ IDs بالسيرفر
  final bool isIncomeProcess;
  final bool isExpenseProcess;
  final bool isFixedIncomeProcess;
  final bool isFixedExpenseProcess;
  final bool isSavingGoalProcess;
  final bool isDebtProcess;

  // Sub-entities populated at the Repository layer during database joins
  final CategoryModel? category;
  final TagEntity? tag;
  final WalletEntity? wallet;

  // Timestamps for audit tracking and synchronization validation logic
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionEntity({
    this.localId,
    this.id,
    this.userId,
    required this.title,
    required this.amount,
    this.amountInSp = 0.0, // القيمة الافتراضية للـ Parameter
    required this.date,
    this.description,
    required this.isSynced,
    this.isDeleted = false,
    this.walletId,
    this.walletLocalId,
    this.categoryId,
    this.expenseTagId,
    required this.isExpense,
    this.currency = "SYR",

    // تمرير الأعلام الجديدة في الباني وإسناد قيم افتراضية false لها
    this.isIncomeProcess = false,
    this.isExpenseProcess = false,
    this.isFixedIncomeProcess = false,
    this.isFixedExpenseProcess = false,
    this.isSavingGoalProcess = false,
    this.isDebtProcess = false,

    this.category,
    this.tag,
    this.wallet,
    this.createdAt,
    this.updatedAt,
  });
}
