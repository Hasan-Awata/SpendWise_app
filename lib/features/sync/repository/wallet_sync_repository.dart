import 'package:spendwise/features/sync/repository/sync_repository.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class WalletSyncRepository implements SyncRepository<WalletModel> {
  final WalletLocalDatasource local;
  final WalletRemoteDatasource remote;

  WalletSyncRepository({required this.local, required this.remote});

  @override
  Future<void> createByLocalId(int localId) async {
    final wallet = local.getWalletByIsarId(localId);
    if (wallet == null) return;

    // 🔴 منع إعادة الإرسال إذا تم مزامنته مسبقاً
    if (wallet.isSynced == true && wallet.walletId != null) {
      return;
    }

    final remoteWallet = await remote.addWalet(wallet);

    if (remoteWallet != null) {
      wallet
        ..walletId = remoteWallet.walletId
        ..isSynced = true;

      await local.updateWallet(wallet);
    }
  }

  @override
  Future<void> updateByLocalId(int localId) async {
    final wallet = local.getWalletByIsarId(localId);
    if (wallet == null) return;

    // 🔴 إذا غير متزامن فقط نعمل update
    if (wallet.walletId == null) return;

    await remote.updateWallet(wallet);

    wallet.isSynced = true;
    await local.updateWallet(wallet);
  }

  @override
  Future<void> deleteByLocalId(int localId) async {
    final wallet = local.getWalletByIsarId(localId);
    if (wallet == null) return;

    bool isRemoved = false;

    if (wallet.walletId != null && wallet.walletId != -1) {
      isRemoved = await remote.deleteWallet(wallet);
    }

    if (isRemoved) {
      await local.deleteWallet(wallet);
    }
  }
}
