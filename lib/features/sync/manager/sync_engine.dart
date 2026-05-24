// =========================================================================
// كلاس SyncEngine المحدث بالكامل مع إدارة الحالات وفلترة الجداول بدقة
// =========================================================================

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

enum SyncState { idle, loading, success, error }

class SyncEngine {
  final SyncRepository repository;
  final NetworkService network;
  final SyncQueueRepository queueRepository;
  final String table;

  bool _isSyncing = false;

  // 🔥 المتغير المرئي لمراقبة حالة هذا المحرك بالذات
  final Rx<SyncState> syncState = SyncState.idle.obs;

  SyncEngine({
    required this.repository,
    required this.network,
    required this.queueRepository,
    required this.table,
  });

  // ========================================================
  // دالة المزامنة الكاملة للطابور (المحدثة بالفحص الذكي)
  // ========================================================
  Future<void> sync() async {
    if (_isSyncing) return;

    final connected = await network.isConnected;
    if (!connected) return;

    try {
      // 1. جلب الطابور والتحقق مما إذا كان يحتوي على عناصر تخص هذا الجدول
      final queue = await queueRepository.getQueue();
      final myTableItems = queue.where((item) => item.table == table).toList();

      // 2. إذا لم يكن هناك حركات تخص هذا الجدول، نخرج بصمت لمنع ازدحام الـ Logs
      if (myTableItems.isEmpty) return;

      // 3. بدء عملية المزامنة وتحديث الحالة
      _isSyncing = true;
      syncState.value = SyncState.loading;
      print(
        "🚀 SyncEngine [$table]: Starting sync process for ${myTableItems.length} items...",
      );

      for (final item in myTableItems) {
        try {
          switch (item.action) {
            case SyncAction.create:
              await repository.createByLocalId(item.isarId);
              break;
            case SyncAction.update:
              await repository.updateByLocalId(item.isarId);
              break;
            case SyncAction.delete:
              await repository.deleteByLocalId(item.isarId);
              break;
          }

          await queueRepository.removeFromQueue(item.isarId);
        } catch (e) {
          // في حال فشل عنصر (مثل خطأ شبكة)، نتوقف لضمان الترتيب البرمجي
          syncState.value = SyncState.error;
          rethrow; // نرفع الخطأ لكي يراه الـ SyncManager ويتوقف عن بقية الجداول
        }
      }

      // 4. تحديث الحالة عند الاكتمال الناجح لجميع حركات الجدول
      syncState.value = SyncState.success;
      print("✅ SyncEngine [$table]: Complete table sync successful.");
    } catch (e) {
      syncState.value = SyncState.error;
      print("❌ SyncEngine [$table]: Global sync failed: $e");
      rethrow; // نرفع الاستثناء لـ SyncManager ليعلم بالفشل الشامل
    } finally {
      _isSyncing = false;
      // إعادة الحالة لوضع الخمول بعد فترة وجيزة
      _resetStateToIdle();
    }
  }

  // ========================================================
  // دالة مزامنة آخر عنصر مضاف إلى الطابور فقط
  // ========================================================
  Future<void> syncLastItem() async {
    if (_isSyncing) {
      print(
        "⏳ SyncEngine [$table]: Engine is busy, skipping immediate single item sync...",
      );
      return;
    }

    final connected = await network.isConnected;
    if (!connected) return;

    try {
      final queue = await queueRepository.getQueue();
      if (queue.isEmpty) {
        return;
      }

      final lastItem = queue.last;

      // 🔥 الحماية الحرجة: تأكد أن العنصر الأخير يخص الجدول الذي يديره هذا المحرك بالذات
      if (lastItem.table != table) {
        return;
      }

      _isSyncing = true;
      syncState.value = SyncState.loading;
      print(
        "🚀 SyncEngine [$table]: Syncing last added item with Action [${lastItem.action.name}] and ID [${lastItem.localId}]...",
      );

      switch (lastItem.action) {
        case SyncAction.create:
          await repository.createByLocalId(lastItem.isarId);
          break;
        case SyncAction.update:
          await repository.updateByLocalId(lastItem.isarId);
          break;
        case SyncAction.delete:
          await repository.deleteByLocalId(lastItem.isarId);
          break;
      }

      await queueRepository.removeFromQueue(lastItem.isarId);
      syncState.value = SyncState.success;
      print(
        "✅ SyncEngine [$table]: Last item synchronized and removed from queue.",
      );
    } catch (e) {
      syncState.value = SyncState.error;
      print("❌ SyncEngine [$table]: Failed to sync last item due to error: $e");
      rethrow;
    } finally {
      _isSyncing = false;
      _resetStateToIdle();
    }
  }

  // دالة مساعدة لإعادة ضبط المؤشر بعد انتهاء المعالجة
  void _resetStateToIdle() {
    Future.delayed(const Duration(seconds: 2), () {
      if (syncState.value == SyncState.success ||
          syncState.value == SyncState.error) {
        syncState.value = SyncState.idle;
      }
    });
  }
}
