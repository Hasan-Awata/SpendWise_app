import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:spendwise/features/category/data/models/category_model.dart';
import 'package:spendwise/features/expense/data/models/product_model.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart' show Uuid;
// lib/features/expense/domain/entities/expense_entity.dart

class ExpenseEntity {
  final String localId;
  int? id;
  final int? userId;
  String title;
  double amount;
  final DateTime date;

  // الحقول الجديدة لتتبع توزيع الخصم
  double amountFromRegular;
  double amountFromSavings;

  final String? description;
  final List<ProductModel>? products;

  RxBool isSynced;
  bool isDeleted;

  int? walletId;
  String? walletLocalId;
  int? currencyId;
  int? categoryId;
  int? expenseTagId;

  final bool? isFixed;

  CategoryModel? category;
  TagEntity? tag;
  WalletEntity? wallet;

  DateTime? createdAt;
  DateTime? updatedAt;
  final bool? isOverLimit;

  ExpenseEntity({
    String? localId,
    RxBool? isSynced,
    this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.date,
    this.amountFromRegular = 0.0,
    this.amountFromSavings = 0.0,
    this.description,
    this.products,
    this.isDeleted = false,
    this.walletId,
    this.currencyId,
    this.walletLocalId,
    this.categoryId,
    this.expenseTagId,
    this.isFixed = false,
    this.category,
    this.tag,
    this.wallet,
    this.createdAt,
    this.updatedAt,
    this.isOverLimit,
  }) : isSynced = isSynced ?? false.obs,
       localId = localId ?? const Uuid().v4();
}
