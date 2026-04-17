// // تعليق: مصدر بيانات المحفظة المصلح مع معالجة دقيقة لعمليات الحذف والتكرار
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
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox(_boxName);
      } else {
        _box = Hive.box(_boxName);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WalletModel>> myWallets() async {
    try {
      final data = _box.get(_walletKey);
      if (data == null) return [];
      // استخدام cast لضمان تحويل القائمة بشكل سليم
      return List<WalletModel>.from(data);
    } catch (e) {
      return [];
    }
  }

  // // تعليق: دالة حفظ ذكية تقوم بالتحديث إذا كان العنصر موجوداً أو الإضافة إذا كان جديداً
  @override
  Future<void> addWaletLocal(WalletModel wallet) async {
    List<WalletModel> wallets = await myWallets();

    // البحث عن وجود المحفظة مسبقاً لمنع التكرار
    int index = wallets.indexWhere(
      (w) =>
          (w.localId == wallet.localId) ||
          (w.walletId != null && w.walletId == wallet.walletId) ||
          (w.currency.currencyName == wallet.currency.currencyName),
    );

    if (index != -1) {
      wallets[index] = wallet; // تحديث
    } else {
      wallets.insert(0, wallet); // إضافة جديد
    }

    await _box.put(_walletKey, wallets);
  }

  @override
  Future<void> deleteWallet(WalletModel wallet) async {
    try {
      List<WalletModel> wallets = await myWallets();

      // تم إصلاح المنطق: الحذف يتم دائماً بناءً على localId لأنه فريد وثابت محلياً
      wallets.removeWhere((w) => w.localId == wallet.localId);

      await _box.put(_walletKey, wallets);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    try {
      List<WalletModel> wallets = await myWallets();
      int index = wallets.indexWhere((w) => w.localId == wallet.localId);

      if (index != -1) {
        wallets[index] = wallet;
        await _box.put(_walletKey, wallets);
      } else {
        throw Exception("المحفظة غير موجودة لتحديثها");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearWallets() async {
    try {
      await _box.delete(
        _walletKey,
      ); // حذف المفتاح بالكامل أسرع من وضع مصفوفة فارغة
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WalletModel?> getWallet(int id) async {
    final wallets = await myWallets();
    try {
      // البحث عن المحفظة بناءً على المعرف القادم من السيرفر
      return wallets.firstWhere((w) => w.walletId == id);
    } catch (e) {
      return null;
    }
  }
}
