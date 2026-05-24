import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:spendwise/features/category/data/models/category_model.dart';
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

  RxBool isSynced;
  bool isDeleted;

  int? walletId;
  String? walletLocalId;
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
    RxBool? isSynced,
    this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.date,
    this.description,
    this.products,
    this.isDeleted = false,
    this.walletId,
    this.walletLocalId,
    this.categoryId,
    this.expenseTagId,
    this.isFixed = false,
    this.category,
    this.tag,
    this.wallet,
    this.createdAt,
    this.updatedAt,
  }) : isSynced = isSynced ?? false.obs,
       localId = localId ?? const Uuid().v4();
}
