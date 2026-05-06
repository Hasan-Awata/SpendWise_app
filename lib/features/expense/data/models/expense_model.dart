// // ExpenseModel updated to match C# ExpenseDTO constraints and naming conventions
import 'package:spendwise/features/category/data/model/category_model.dart'
    show CategoryModel;
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class ExpenseModel extends ExpenseEntity {
  String localId;
  @override
  bool isSynced;

  ExpenseModel({
    String? localId,
    super.id,
    super.userId,
    required super.title,
    required super.amount,
    required super.date,
    TagModel? super.tag,
    super.description,
    super.wallet,
    super.category,
    super.products,
    int? walletId,
    int? categoryId,
    int? expenseTagId,
    this.isSynced = false,
  }) : localId = localId ?? const Uuid().v4(),
       super(
         walletId: walletId ?? wallet?.walletId ?? 0,
         categoryId: categoryId ?? category?.categoryId ?? 0,
         expenseTagId: expenseTagId ?? tag?.id ?? 0,
       );

  factory ExpenseModel.fromJson(Map<dynamic, dynamic> json) {
    return ExpenseModel(
      // // C# DTO uses 'ExpenseId' as the primary key name
      id: json['expenseId'] ?? json['ExpenseId'] ?? -1,
      localId: json['localId'] ?? const Uuid().v4(),
      userId: json['userId'] ?? json['UserId'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      // // Ensure double conversion for amount
      amount: (json['amount'] ?? json['Amount'] ?? 0.0).toDouble(),
      date: _dateFromJson(json),
      description: json['description'] ?? json['Description'] ?? '',
      products: json['products'] ?? json['Products'] ?? '',
      walletId: json['walletId'] ?? json['WalletId'] ?? 0,
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? 0,
      expenseTagId: json['expenseTagId'] ?? json['ExpenseTagId'] ?? 0,
      tag: _tagFromJson(json['expenseTag'] ?? json['ExpenseTag']),
      category: _categoryFromJson(json['category'] ?? json['Category']),

      isSynced: true,
    );
  }

  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      // // Consistent naming with C# DTO (PascalCase in C# usually maps to camelCase in JSON)
      'expenseId': isCreate ? -1 : (id ?? -1),
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description ?? '',
      'products': products ?? "",
      'walletId': (walletId != null && walletId! > 0)
          ? walletId
          : (wallet?.walletId ?? 0),
      'categoryId': (categoryId != null && categoryId! > 0)
          ? categoryId
          : (category?.categoryId ?? 0),
      'expenseTagId': (expenseTagId != null && expenseTagId! > 0)
          ? expenseTagId
          : (tag?.id ?? 0),
    };
  }

  factory ExpenseModel.fromLocal(Map<dynamic, dynamic> map) {
    return ExpenseModel(
      localId: map['localId'],
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      description: map['description'],
      products: map['products'],
      walletId: map['walletId'],
      categoryId: map['categoryId'],
      expenseTagId: map['expenseTagId'],
      isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
      tag: map['tag'] != null
          ? TagModel.fromLocal(Map<String, dynamic>.from(map['tag']))
          : null,
      category: map['category'] != null
          ? CategoryModel.fromJson(Map<String, dynamic>.from(map['category']))
          : null,
    );
  }

  Map<dynamic, dynamic> toLocal() {
    return {
      'localId': localId,
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'products': products,
      'walletId': walletId,
      'categoryId': categoryId,
      'expenseTagId': expenseTagId,
      'isSynced': isSynced ? 1 : 0,
      'tag': tag is TagModel ? (tag as TagModel).toLocal() : null,
      'category': category is CategoryModel
          ? (category as CategoryModel).toJson()
          : null,
      'wallet': wallet is WalletModel
          ? (wallet as WalletModel).toLocal()
          : null,
    };
  }

  static CategoryModel? _categoryFromJson(dynamic raw) {
    if (raw == null) return null;
    if (raw is CategoryModel) return raw;
    if (raw is Map)
      return CategoryModel.fromJson(Map<String, dynamic>.from(raw));
    return null;
  }

  static TagModel? _tagFromJson(dynamic raw) {
    if (raw == null) return null;
    if (raw is TagModel) return raw;
    if (raw is Map) return TagModel.fromJson(Map<String, dynamic>.from(raw));
    return null;
  }

  static WalletModel? _walletFromJson(dynamic raw) {
    if (raw is WalletModel) return raw;
    if (raw is Map)
      return WalletModel.fromJson(Map<dynamic, dynamic>.from(raw));
    return null;
  }

  static DateTime _dateFromJson(Map<dynamic, dynamic> json) {
    final v = json['Date'] ?? json['date'] ?? json['Date'];
    if (v == null) return DateTime.now();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, title: $title, amount: $amount, walletId: $walletId, expenseTagId: $expenseTagId)';
  }
}
