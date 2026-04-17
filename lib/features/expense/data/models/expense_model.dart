// // Logic: features/expense/data/models/expense_model.dart
import 'package:spendwise/features/category/data/model/category_model.dart'
    show CategoryModel;
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

// تم تحديث الموديل ليدعم الفصل التام بين بيانات التخزين المحلي وبيانات السيرفر
class ExpenseModel extends ExpenseEntity {
  bool isSynced;
  String localId;

  ExpenseModel({
    String? localId,
    super.id,
    super.userId,
    required super.title,
    required super.amount,
    required super.date,
    super.tag,
    super.description,
    super.wallet,
    super.category,
    super.products,
    this.isSynced = false,
  }) : localId = localId ?? const Uuid().v4();

  // دالة مخصصة لتحويل البيانات القادمة من السيرفر (API)
  factory ExpenseModel.fromJson(Map<dynamic, dynamic> json) {
    final idVal = json['ExpenseId'] ?? json['id'];
    return ExpenseModel(
      id: idVal != null ? (idVal as num).toInt() : null,
      localId: const Uuid().v4(), // السيرفر لا يرسل معرفاً محلياً
      userId: (json['UserId'] ?? json['userId'] ?? 0) as int,
      title: (json['Title'] ?? json['title'] ?? '') as String,
      amount: (json['Amount'] ?? json['amount'] ?? 0.0).toDouble(),
      date: _dateFromJson(json),
      tag: _tagFromJson(json['ExpenseTag'] ?? json['tag']),
      category: _categoryFromJson(json['Category'] ?? json['category']),
      description: (json['Description'] ?? json['description'] ?? '') as String,
      products: (json['Products'] ?? json['products'] ?? '') as String,
      wallet: _walletFromJson(json['Wallet'] ?? json['wallet']),
      isSynced: true, // البيانات القادمة من السيرفر متزامنة دائماً
    );
  }

  // دالة جديدة: لاسترجاع المصاريف المخزنة في قاعدة البيانات المحلية بالكامل
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
      isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
      // استعادة الكائنات المرتبطة عبر دوال الـ Local الخاصة بها
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

  // لتحويل الكائن إلى JSON متوافق مع متطلبات السيرفر (Backend)
  Map<String, dynamic> toJson() {
    return {
      'ExpenseId': id ?? -1,
      'UserId': userId,
      'Title': title,
      'Amount': amount,
      'Date': date.toIso8601String(),
      'Description': description ?? '',
      'Products': products ?? "",
      'WalletId': wallet!.walletId,
      'CategoryId': category!.categoryId,
      'ExpenseTagId': tag!.id,
    };
  }

  // دالة جديدة: لحفظ الحالة الكاملة للمصروف في التخزين المحلي
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

  // المنطق الخاص بمعالجة البيانات المتداخلة (Helper Methods)
  static CategoryModel? _categoryFromJson(dynamic raw) {
    if (raw == null) return null;
    if (raw is CategoryModel) return raw;
    if (raw is Map) {
      return CategoryModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static TagModel? _tagFromJson(dynamic raw) {
    if (raw == null) return null;
    if (raw is TagModel) return raw;
    if (raw is Map) {
      return TagModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static WalletModel? _walletFromJson(dynamic raw) {
    if (raw is WalletModel) return raw;
    if (raw is Map) {
      return WalletModel.fromJson(Map<dynamic, dynamic>.from(raw));
    }
    return null;
  }

  static DateTime _dateFromJson(Map<dynamic, dynamic> json) {
    final v = json['Date'] ?? json['date'];
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  @override
  String toString() {
    return 'ExpenseModel(localId: $localId, id: $id, title: $title, amount: $amount, date: $date, isSynced: $isSynced, wallet: ${wallet?.currency.currencyName}, category: ${category?.name})';
  }
}
