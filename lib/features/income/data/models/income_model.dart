import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class IncomeModel extends IncomeEntity {
  bool isSynced;
  IncomeModel({
    super.id,
    required super.title,
    required super.amount,
    required super.date,
    super.tag,
    super.description,
    super.wallet,
    this.isSynced = false,
  });

  static TagModel? _tagFromJson(dynamic raw) {
    if (raw == null) return null;
    if (raw is TagModel) return raw;
    if (raw is Map) {
      final m = Map<dynamic, dynamic>.from(raw);
      return TagModel(
        id: m['TagID'] ?? m['id'],
        userId: (m['userId'] as num?)?.toInt() ?? 0,
        name: (m['name'] ?? '') as String,
      );
    }
    return null;
  }

  static WalletModel? _walletFromJson(dynamic raw) {
    if (raw == null) return null;
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
    return DateTime.parse(v.toString());
  }

  // // Logic: Creating the model from JSON with all descriptors included
  factory IncomeModel.fromJson(Map<dynamic, dynamic> json) {
    final idVal = json['Id'] ?? json['id'];
    return IncomeModel(
      id: idVal != null ? (idVal as num).toInt() : null,
      title: (json['Title'] ?? json['title'] ?? '') as String,
      amount: (json['amount'] ?? json['Amount'] ?? 0.0).toDouble(),
      date: _dateFromJson(json),
      tag: _tagFromJson(json['IncomeTag'] ?? json['tag']),
      description: (json['description'] ?? '') as String,
      wallet: _walletFromJson(json['Wallet'] ?? json['wallet']),
      isSynced: json['isSynced'] == true,
    );
  }

  // // Logic: Converting the model back to JSON including tag and description
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'IncomeTag': tag?.toJson(),
      'description': description ?? '',
      'Wallet': wallet?.toJson(),
      'isSynced': isSynced,
    };
  }
}
