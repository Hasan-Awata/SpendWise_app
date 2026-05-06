// // Updated IncomeModel with Wallet retrieval logic
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:uuid/uuid.dart';

class IncomeModel extends IncomeEntity {
  String localId;
  bool isSynced;

  IncomeModel({
    String? localId,
    int super.id,
    super.userId = 0,
    required super.title,
    super.walletId = 0,
    required super.amount,
    required super.date,
    super.incomeTagId,
    required super.description,
    super.wallet,
    this.isSynced = false,
    super.tag,
  }) : localId = localId ?? const Uuid().v4();

  // ========================= FROM API =========================
  factory IncomeModel.fromJson(Map<dynamic, dynamic> json) {
    final int wId = json['walletId'] ?? 0;

    return IncomeModel(
      localId: json['localId'] ?? const Uuid().v4(),
      id: json['id'] ?? -1,
      userId: json['userId'] ?? 0,
      title: json['title'] ?? '',
      walletId: wId,
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      incomeTagId: json['incomeTagId'],
      description: json['description'] ?? '',
      isSynced: true,
      tag: json['tag'] != null ? TagModel.fromJson(json['tag']) : null,
    );
  }

  // ========================= FROM LOCAL =========================
  factory IncomeModel.fromLocal(Map<dynamic, dynamic> map) {
    final int wId = map['walletId'] ?? 0;

    return IncomeModel(
      localId: map['localId'],
      id: map['id'] ?? -1,
      userId: map['userId'] ?? 0,
      title: map['title'] ?? '',
      walletId: wId,
      amount: (map['amount'] ?? 0).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      incomeTagId: map['incomeTagId'],
      description: map['description'] ?? '',
      isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
    );
  }

  //

  // ========================= TO API & LOCAL =========================
  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      if (!isCreate) 'id': id,
      'userId': userId,
      'title': title,
      'walletId': walletId != 0 ? walletId : wallet?.walletId,
      'amount': amount,
      'date': date.toUtc().toIso8601String(),
      'incomeTagId': incomeTagId ?? tag?.id ?? 1,
      'description': description,
    };
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
      'incomeTagId': incomeTagId ?? tag?.id,
      'description': description,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'IncomeModel(localId: $localId, id: $id, title: $title, amount: $amount, date: $date, walletId: $walletId, walletName: ${wallet?.currency.currencyName}, isSynced: $isSynced)';
  }
}
