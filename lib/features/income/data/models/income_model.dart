// // Matching the model properties with IncomeEntity and Backend DTO PascalCase names
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class IncomeModel extends IncomeEntity {
  String localId;
  bool isSynced;

  IncomeModel({
    String? localId,
    int id = -1,
    int userId = 0,
    required String title,
    int walletId = 0,
    required double amount,
    required DateTime date,
    int? incomeTagId,
    required String description,
    WalletModel? wallet,
    this.isSynced = false,
    TagModel? tag,
  }) : localId = localId ?? const Uuid().v4(),
       super(
         id: id,
         userId: userId,
         title: title,
         walletId: walletId,
         amount: amount,
         date: date,
         incomeTagId: incomeTagId,
         description: description,
         wallet: wallet,
         tag: tag,
       );

  // تحويل البيانات القادمة من API (PascalCase) إلى Model
  factory IncomeModel.fromJson(Map<dynamic, dynamic> json) {
    return IncomeModel(
      localId: const Uuid().v4(),
      id: json['Id'] ?? -1,
      userId: json['UserId'] ?? 0,
      title: json['Title'] ?? '',
      walletId: json['WalletId'] ?? 0,
      amount: (json['Amount'] ?? 0.0).toDouble(),
      date: json['Date'] != null
          ? DateTime.parse(json['Date'])
          : DateTime.now(),
      incomeTagId: json['IncomeTagId'],
      description: json['Description'] ?? '',
      // إذا كان الباكيند يرسل كائن المحفظة كاملاً
      wallet: json['Wallet'] != null
          ? WalletModel.fromJson(json['Wallet'])
          : null,
      isSynced: true,
    );
  }

  // تحويل الكائن إلى JSON لإرساله إلى الباكيند (PascalCase)
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'UserId': userId,
      'Title': title,
      'WalletId': walletId,
      'Amount': amount,
      'Date': date.toIso8601String(),
      'IncomeTagId': incomeTagId,
      'Description': description,
    };
  }

  // التعامل مع التخزين المحلي (عادة نستخدم snake_case أو camelCase للمحلي)
  factory IncomeModel.fromLocal(Map<dynamic, dynamic> map) {
    return IncomeModel(
      localId: map['localId'],
      id: map['id'] ?? -1,
      userId: map['userId'] ?? 0,
      title: map['title'] ?? '',
      walletId: map['walletId'] ?? 0,
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      incomeTagId: map['incomeTagId'],
      description: map['description'] ?? '',
      isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
    );
  }

  Map<dynamic, dynamic> toLocal() {
    return {
      'localId': localId,
      'id': id,
      'userId': userId,
      'title': title,
      'walletId': walletId,
      'amount': amount,
      'date': date.toIso8601String(),
      'incomeTagId': incomeTagId,
      'description': description,
      'isSynced': isSynced ? 1 : 0,
    };
  }
}
