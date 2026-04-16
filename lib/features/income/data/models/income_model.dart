import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

// تم فصل منطق IncomeModel للتعامل بدقة مع قواعد البيانات المحلية وواجهة البرمجيات (API)
class IncomeModel extends IncomeEntity {
  String localId;
  bool isSynced;

  IncomeModel({
    String? localId,
    super.remoteId,
    super.userId,
    required super.title,
    required super.amount,
    required super.date,
    super.tag,
    super.description,
    super.wallet,
    this.isSynced = false,
  }) : localId = localId ?? const Uuid().v4();

  // دالة مخصصة لاستقبال البيانات من السيرفر (Backend)
  factory IncomeModel.fromJson(Map<dynamic, dynamic> json) {
    final idVal = json['Id'] ?? json['id'];
    return IncomeModel(
      localId: const Uuid()
          .v4(), // بيانات السيرفر لا تحتوي localId فننشئ واحداً جديداً
      remoteId: idVal != null ? (idVal as num).toInt() : null,
      title: (json['Title'] ?? json['title'] ?? '') as String,
      amount: (json['Amount'] ?? json['amount'] ?? 0.0).toDouble(),
      date: _dateFromJson(json),
      tag: _tagFromJson(json['IncomeTag'] ?? json['tag']),
      description: (json['Description'] ?? json['description'] ?? '') as String,
      wallet: _walletFromJson(json['Wallet'] ?? json['wallet']),
      isSynced: true, // البيانات القادمة من السيرفر متزامنة افتراضياً
    );
  }

  // دالة مخصصة لاسترجاع البيانات من التخزين المحلي (SQLite/Hive)
  factory IncomeModel.fromLocal(Map<dynamic, dynamic> map) {
    return IncomeModel(
      localId: map['localId'],
      remoteId: map['remoteId'],
      userId: map['userId'],
      title: map['title'] ?? "",
      amount: map['amount'] ?? 0.0,
      date: DateTime.now(),
      // date: map['date'] != null
      //     ? DateTime.fromMillisecondsSinceEpoch(
      //         int.parse(map['date'].toString()),
      //       )
      //     : DateTime.now(),
      description: map['description'],
      isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
      // نفترض هنا أن البيانات المتداخلة تُخزن كـ Map أو يتم معالجتها عبر IDs
      tag: map['Tag'] != null
          ? TagModel.fromLocal(Map<String, dynamic>.from(map['tag']))
          : null,
      wallet: map['wallet'] != null
          ? WalletModel.fromLocal(Map<String, dynamic>.from(map['wallet']))
          : null,
    );
  }

  // لتحويل الكائن إلى صيغة يقبلها السيرفر (تجاهل الـ localId والبيانات غير الضرورية)
  Map<dynamic, dynamic> toJson() {
    return {
      'UserId': userId,
      'Id': remoteId,
      'Title': title,
      'Amount': amount,
      'Date': date.toIso8601String(),
      'Description': description ?? '',
      'Wallet': wallet, // غالباً السيرفر يحتاج الـ ID فقط للكائنات المرتبطة
      'IncomeTag': tag,
    };
  }

  // لتحويل الكائن إلى صيغة التخزين المحلي (حفظ الحالة الكاملة)
  Map<dynamic, dynamic> toLocal() {
    return {
      'localId': localId,
      'remoteId': remoteId,
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'isSynced': isSynced ? 1 : 0,
      'tag': tag is TagModel ? (tag as TagModel).toLocal() : null,
      'wallet': wallet is WalletModel
          ? (wallet as WalletModel).toLocal()
          : null,
    };
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
    final v = json['date'] ?? json['Date'];
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }
}
