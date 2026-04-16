import 'package:spendwise/features/category/data/model/category_model.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';

class ExpenseEntity {
  final int? id;
  final int? userId;
  final String title;
  double amount;
  final DateTime date;
  final TagEntity? tag;
  final String? description;
  final WalletEntity? wallet;
  final CategoryModel? category;
  final String? products; // JSON string
  final bool isSynced;

  ExpenseEntity({
    this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.date,
    this.tag,
    this.description,
    this.wallet,
    this.category,
    this.products,
    this.isSynced = false,
  });
}
