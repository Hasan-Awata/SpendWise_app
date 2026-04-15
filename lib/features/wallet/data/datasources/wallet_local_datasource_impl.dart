import 'package:hive/hive.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

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
    try {
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addWaletLocal(WalletModel wallet) async {
    // if (wallet.walletId == null) return; // حماية

    final wallets = await myWallets();

    try {
      final updatedWallets = List<WalletModel>.from(wallets)..insert(0, wallet);

      await _box.put(_walletKey, updatedWallets);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WalletModel?> getWallet(int id) async {
    final wallets = await myWallets();
    try {
      if (wallets.isEmpty) {
        return null;
      }
      return wallets.firstWhere((wallet) => wallet.walletId == id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WalletModel>> myWallets() async {
    try {
      final data = await _box.get(_walletKey);
      if (data == null || data is! List) {
        return [];
      }
      return data.cast<WalletModel>().toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearWallets() async {
    try {
      await _box.put(_walletKey, []); // بدل delete
    } catch (e) {
      rethrow;
    }
  }
}
