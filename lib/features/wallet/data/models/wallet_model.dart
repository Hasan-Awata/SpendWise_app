import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/features/sync/model/syncable_model.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

part 'wallet_model.g.dart';

@collection
class WalletModel implements SyncableModel {
  Id isarId = Isar.autoIncrement;

  @override
  int? get serverId {
    if (walletId == null || walletId! <= 0) return null;
    return walletId;
  }

  @Index(unique: true)
  String localId;

  @Index()
  int? walletId;

  int userId;
  double balance;
  int currencyId;

  @override
  bool isSynced;
  @override
  bool isDeleted;
  bool isSaved;

  @ignore
  Currency? currency;

  @ignore
  WalletModel? wallet;

  int numberOfTransactions; // عدد المعاملات المرتبطة بالمحفظة

  // =====================================================
  // SYNC RETRY SYSTEM
  // =====================================================

  @override
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
    this.numberOfTransactions = 0,
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
    numberOfTransactions = 0,
    bool isSaved = false,
    bool isSynced = false,
    bool isDeleted = false,
  }) {
    return WalletModel(
      localId: localId ?? const Uuid().v4(),
      walletId: walletId,
      numberOfTransactions: numberOfTransactions,
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
      isSynced: entity.isSynced.value,
      isDeleted: entity.isDeleted,
      numberOfTransactions: entity.numberOfTransactions,
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
      isSynced: isSynced.obs,
      isDeleted: isDeleted,
      currency: currency ?? Currency(code: "", currencyName: ""),
      createdAt: createdAt,
      updatedAt: updatedAt,
      numberOfTransactions: numberOfTransactions,
    );
  }

  // =====================================================
  // JSON
  // =====================================================

  factory WalletModel.fromJson(Map<String, dynamic> json, {String? localId}) {
    return WalletModel(
      localId: localId ?? const Uuid().v4(),
      walletId: int.tryParse((json["walletId"] ?? json["id"] ?? "").toString()),
      userId:
          int.tryParse((json["userId"] ?? json["UserId"] ?? 0).toString()) ?? 0,
      balance:
          double.tryParse(
            (json["balance"] ?? json["Balance"] ?? 0).toString(),
          ) ??
          0.0,
      currencyId:
          int.tryParse(
            (json["currencyId"] ?? json["CurrencyId"] ?? 0).toString(),
          ) ??
          0,
      isSaved: json["isSaved"] ?? json["IsSaved"] ?? false,
      isSynced: true,
      isDeleted: false,
      numberOfTransactions:
          json["numberOfTransactions"] ?? json["NumberOfTransactions"] ?? 0,
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
    int? numberOfTransactions,
    Currency? currency,
    WalletModel? wallet,
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
        numberOfTransactions: numberOfTransactions ?? this.numberOfTransactions,
      )
      ..isarId = isarId ?? this.isarId
      ..currency = currency ?? this.currency
      ..wallet = wallet ?? this.wallet;
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

  @override
  void markSynced(int id) {
    walletId = id;
    isSynced = true;
    isDeleted = false;
    syncAttempts = 0;
    lastSyncError = null;
    updatedAt = DateTime.now();
  }
}
