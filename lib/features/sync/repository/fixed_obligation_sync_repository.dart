import 'package:spendwise/features/fixed_obligations/data/datasources/fixed_obligation_local_datasource.dart';
import 'package:spendwise/features/fixed_obligations/data/datasources/fixed_obligation_remote_datasource.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

class FixedObligationSyncRepository
    implements SyncRepository<FixedObligationModel> {
  final FixedObligationLocalDataSource local;
  final FixedObligationRemoteDataSource remote;

  FixedObligationSyncRepository({required this.local, required this.remote});

  @override
  Future<void> createByLocalId(int isarId) async {
    final fixedObligation = await local.getFixedObligationByIsarId(isarId);
    if (fixedObligation == null) return;

    if (fixedObligation.isSynced == true) return;

    try {
      // 1. استدعاء السيرفر (يبقى كما هو)
      final remoteFixedObligation = await remote.addFixedObligation(
        fixedObligation,
      );

      if (remoteFixedObligation != null) {
        // 2. تحديث الموديل بالحالة القادمة من السيرفر
        fixedObligation
          ..id = remoteFixedObligation.id
          ..isSynced = true;

        await local.saveFixedObligation(fixedObligation);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateByLocalId(int isarId) async {
    final fixedObligation = await local.getFixedObligationByIsarId(isarId);
    if (fixedObligation == null) return;

    try {
      await remote.updateFixedObligation(fixedObligation);

      fixedObligation.isSynced = true;
      await local.saveFixedObligation(fixedObligation);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteByLocalId(int isarId) async {
    final fixedObligation = await local.getFixedObligationByIsarId(isarId);
    if (fixedObligation == null) return;

    try {
      bool isRemoved = false;

      // 🔴 إذا غير موجود على السيرفر نحذفه محلياً مباشرة
      if (fixedObligation.id == -1) {
        await local.deleteFixedObligation(fixedObligation.isarId);
        return;
      }

      isRemoved = await remote.deleteFixedObligation(fixedObligation.isarId);

      if (isRemoved) {
        await local.deleteFixedObligation(fixedObligation.isarId);
      }
    } catch (e) {
      rethrow;
    }
  }
}
