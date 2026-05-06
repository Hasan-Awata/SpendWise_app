import 'package:hive/hive.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class WalletLocalDatasourceImpl implements WalletLocalDatasource {
  static final WalletLocalDatasourceImpl _instance =
      WalletLocalDatasourceImpl._internal();
  WalletLocalDatasourceImpl._internal();
  factory WalletLocalDatasourceImpl() => _instance;

  static const String _boxName = 'WALLET';
  static const String _walletKey = 'wallet_key';

  late Box _box;

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  @override
  Future<List<WalletModel>> myWallets() async {
    final data = _box.get(_walletKey);
    if (data == null) return [];
    return List<WalletModel>.from(data);
  }

  @override
  Future<void> addWaletLocal(WalletModel wallet) async {
    List<WalletModel> wallets = await myWallets();

    if (wallet.localId == null || wallet.localId!.isEmpty) {
      wallet.localId = const Uuid().v4();
    }

    int index = wallets.indexWhere((w) {
      if (wallet.walletId != null && wallet.walletId != -1) {
        return w.walletId == wallet.walletId;
      }
      return w.localId == wallet.localId;
    });

    if (index != -1) {
      wallets[index] = wallet;
    } else {
      wallets.insert(0, wallet);
    }

    await _box.put(_walletKey, wallets);
  }

  @override
  Future<void> deleteWallet(WalletModel wallet) async {
    List<WalletModel> wallets = await myWallets();
    wallets.removeWhere((w) => w.localId == wallet.localId);
    await _box.put(_walletKey, wallets);
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    List<WalletModel> wallets = await myWallets();

    int index = wallets.indexWhere((w) => w.localId == wallet.localId);

    if (index == -1 && wallet.walletId != null) {
      index = wallets.indexWhere((w) => w.walletId == wallet.walletId);
    }

    if (index != -1) {
      wallets[index] = wallet;
    } else {
      if (wallet.localId == null || wallet.localId!.isEmpty) {
        wallet.localId = const Uuid().v4();
      }
      wallets.insert(0, wallet);
    }

    await _box.put(_walletKey, wallets);
  }

  @override
  Future<void> clearWallets() async {
    await _box.delete(_walletKey);
  }

  @override
  WalletModel? getWallet(dynamic id) {
    try {
      // 1. محاولة البحث كـ integer (معرف السيرفر)
      if (id is int || int.tryParse(id.toString()) != null) {
        final intId = int.parse(id.toString());
        final walletByServerId = _box.values.firstOrNull(
          (w) => w.walletId == intId,
        );
        if (walletByServerId != null) return walletByServerId;
      }

      // 2. محاولة البحث كـ String (المعرف المحلي UUID)
      final walletByLocalId = _box.values.firstOrNull(
        (w) => w.localId == id.toString(),
      );
      return walletByLocalId;
    } catch (e) {
      print("❌ Error in getWallet: $e");
      return null;
    }
  }
}
