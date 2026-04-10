// // تعليق: تنفيذ المستودع الذي يربط بين طبقة البيانات وطبقة منطق الأعمال باستخدام Datasource
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDatasource localDatasource;

  WalletRepositoryImpl({required this.localDatasource});

  @override
  Future<void> addWallet(WalletModel wallet) async {
    return await localDatasource.addWaletLocal(wallet);
  }

  @override
  Future<List<WalletModel>> getMyWallets() async {
    return await localDatasource.myWallets();
  }

  @override
  Future<WalletModel?> getWalletById(int id) async {
    return await localDatasource.getWallet(id);
  }
}
