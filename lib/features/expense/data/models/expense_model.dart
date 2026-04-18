// // Logic: features/expense/data/models/expense_model.dart
import 'package:spendwise/features/category/data/model/category_model.dart'
    show CategoryModel;
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class ExpenseModel extends ExpenseEntity {
  String localId;
  bool isSynced;

  ExpenseModel({
    String? localId,
    int? id,
    int? userId,
    required String title,
    required double amount,
    required DateTime date,
    TagModel? tag,
    String? description,
    WalletModel? wallet,
    CategoryModel? category,
    String? products,
    int? walletId,
    int? categoryId,
    int? expenseTagId,
    this.isSynced = false,
  }) : localId = localId ?? const Uuid().v4(),
       super(
         id: id,
         userId: userId,
         title: title,
         amount: amount,
         date: date,
         tag: tag,
         description: description,
         wallet: wallet,
         category: category,
         products: products,
         walletId: walletId ?? wallet?.walletId ?? -1,
         categoryId: categoryId ?? category?.categoryId ?? -1,
         expenseTagId: expenseTagId ?? tag?.id ?? -1,
       );

  // دالة مخصصة لتحويل البيانات القادمة من السيرفر (API) بنفس مسميات الـ PascalCase
  factory ExpenseModel.fromJson(Map<dynamic, dynamic> json) {
    return ExpenseModel(
      id: json['Id'] ?? json['ExpenseId'] ?? -1,
      localId: const Uuid().v4(),
      userId: json['UserId'] ?? 0,
      title: json['Title'] ?? '',
      amount: (json['Amount'] ?? 0.0).toDouble(),
      date: _dateFromJson(json),
      description: json['Description'] ?? '',
      products: json['Products'] ?? '',
      // معالجة الـ IDs المباشرة
      walletId: json['WalletId'] ?? -1,
      categoryId: json['CategoryId'] ?? -1,
      expenseTagId: json['ExpenseTagId'] ?? -1,
      // معالجة الكائنات الكاملة إذا أرسلها السيرفر
      tag: _tagFromJson(json['ExpenseTag'] ?? json['tag']),
      category: _categoryFromJson(json['Category'] ?? json['category']),
      wallet: _walletFromJson(json['Wallet'] ?? json['wallet']),
      isSynced: true,
    );
  }

  // لتحويل الكائن إلى JSON متوافق تماماً مع الـ Backend DTO
  Map<String, dynamic> toJson() {
    return {
      'ExpenseId': id ?? -1,
      'UserId': userId,
      'Title': title,
      'Amount': amount,
      'Date': date.toIso8601String(),
      'Description': description ?? '',
      'Products': products ?? "",
      'WalletId': walletId ?? wallet!.walletId,
      'CategoryId': categoryId ?? category!.categoryId,
      'ExpenseTagId': expenseTagId ?? tag!.id,
    };
  }

  // لاسترجاع البيانات من التخزين المحلي
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
      wallet: map['wallet'] != null
          ? WalletModel.fromLocal(Map<String, dynamic>.from(map['wallet']))
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

  // Helper Methods
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
    final v = json['Date'] ?? json['date'];
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }
}
