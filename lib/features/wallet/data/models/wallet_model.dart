import 'package:isar/isar.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

part 'wallet_model.g.dart';

@collection
class WalletModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String localId;

  @Index()
  int? walletId;

  int userId;
  double balance;
  int currencyId;

  bool isSynced;
  bool isDeleted;
  bool isSaved;

  @ignore
  Currency? currency;

  // =====================================================
  // SYNC RETRY SYSTEM
  // =====================================================

  int syncAttempts;
  DateTime? lastSyncError;

  // =====================================================
  // TIMESTAMPS
  // =====================================================

  DateTime? createdAt;
  DateTime? updatedAt;

  WalletModel({
    required this.localId,
    this.walletId,
    required this.userId,
    required this.balance,
    required this.currencyId,
    this.isSaved = false,
    this.isSynced = false,
    this.isDeleted = false,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // =====================================================
  // SAFE FACTORY
  // =====================================================

  factory WalletModel.create({
    int? walletId,
    required int userId,
    required double balance,
    required int currencyId,
    String? localId,
    bool isSaved = false,
    bool isSynced = false,
    bool isDeleted = false,
  }) {
    return WalletModel(
      localId: localId ?? const Uuid().v4(),
      walletId: walletId,
      userId: userId,
      balance: balance,
      currencyId: currencyId,
      isSaved: isSaved,
      isSynced: isSynced,
      isDeleted: isDeleted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // =====================================================
  // ENTITY MAPPER
  // =====================================================

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      localId: entity.localId,
      walletId: entity.walletId,
      userId: entity.userId,
      balance: entity.balance,
      currencyId: entity.currencyId,
      isSaved: entity.isSaved,
      isSynced: entity.isSynced,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  WalletEntity toEntity() {
    return WalletEntity(
      localId: localId,
      walletId: walletId,
      userId: userId,
      balance: balance,
      currencyId: currencyId,
      isSaved: isSaved,
      isSynced: isSynced,
      isDeleted: isDeleted,
      currency: currency ?? Currency(code: "", currencyName: ""),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // =====================================================
  // JSON
  // =====================================================

  factory WalletModel.fromJson(Map<String, dynamic> json, {String? localId}) {
    return WalletModel(
      localId: localId ?? const Uuid().v4(),
      walletId: json["walletId"] ?? json["id"],
      userId: json["userId"] ?? json["UserId"],
      balance: (json["balance"] ?? json["Balance"] ?? 0).toDouble(),
      currencyId: json["currencyId"] ?? json["CurrencyId"],
      isSaved: json['isSaved'] ?? json['IsSaved'] ?? false,
      isSynced: true,
      isDeleted: false,
    );
  }

  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      "walletId": walletId ?? -1,
      "userId": userId,
      "balance": balance,
      "currencyId": currencyId,
      "isSaved": isSaved,
    };
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  WalletModel copyWith({
    Id? isarId,
    String? localId,
    int? walletId,
    int? userId,
    double? balance,
    int? currencyId,
    bool? isSynced,
    bool? isDeleted,
    bool? isSaved,
    int? syncAttempts,
    DateTime? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      localId: localId ?? this.localId,
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currencyId: currencyId ?? this.currencyId,
      isSaved: isSaved ?? this.isSaved,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    )..isarId = isarId ?? this.isarId;
  }

  // =====================================================
  // DEBUG
  // =====================================================

  @override
  String toString() {
    return '''
WalletModel(
  isarId: $isarId,
  localId: $localId,
  walletId: $walletId,
  userId: $userId,
  balance: $balance,
  currencyId: $currencyId,
  isSaved: $isSaved,
  isSynced: $isSynced,
  isDeleted: $isDeleted,
  syncAttempts: $syncAttempts,
  lastSyncError: $lastSyncError,
  createdAt: $createdAt,
  updatedAt: $updatedAt
)
''';
  }
}
