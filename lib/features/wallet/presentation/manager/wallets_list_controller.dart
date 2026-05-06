// [The following code ensures the controller handles local and remote data without loss]

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_all_wallets_local_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/sync_wallets_usecase.dart';

class WalletsListController extends GetxController {
  final SyncWalletsUseCase syncWalletsUseCase;
  final GetMyWalletsUseCase getMyWalletsUseCase;
  final GetAllWalletsLocalUseCase getAllWalletsLocalUseCase;

  WalletsListController({
    required this.getMyWalletsUseCase,
    required this.syncWalletsUseCase,
    required this.getAllWalletsLocalUseCase,
  });

  final wallets = <WalletModel>[].obs;
  final isLoading = false.obs;
  final totalBalance = 0.0.obs;
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  bool hasMore = true;
  final int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (!isLoading.value && hasMore) {
        loadWallets(isRefresh: false);
      }
    }
  }

  Future<void> loadWallets({bool isRefresh = false}) async {
    if (isLoading.value || (!hasMore && !isRefresh)) return;

    try {
      isLoading.value = true;

      if (isRefresh) {
        currentPage = 1;
        hasMore = true;
      }

      final result = await getMyWalletsUseCase.call(
        PageRequest(pageNumber: currentPage, pageSize: pageSize),
      );

      result.fold(
        (failure) {
          HelperFunction.showSnackBar("تنبيه", failure.message, isError: true);
          // في حال فشل السيرفر، نحاول التحديث من البيانات المحلية كخيار أخير
          _refreshLocalData();
        },
        (pagedResponse) {
          final newItems = pagedResponse.data;
          for (int i = 0; i < newItems.length; i++) {
            print("items   sssssss ${newItems[i]}");
          }
          if (isRefresh) {
            // تحديث القائمة بالكامل بالبيانات الجديدة (سواء كانت كاش أو سيرفر)
            wallets.assignAll(newItems.reversed);
          } else {
            // إضافة العناصر الجديدة مع فحص دقيق جداً للتكرار
            for (var newItem in newItems) {
              bool isDuplicate = wallets.any(
                (existing) =>
                    (newItem.walletId != null &&
                        existing.walletId == newItem.walletId) ||
                    (existing.localId == newItem.localId),
              );

              if (!isDuplicate) {
                wallets.add(newItem);
              }
            }
          }

          if (newItems.length < pageSize) {
            hasMore = false;
          } else {
            currentPage++;
          }
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  // دالة لجلب كل البيانات المحلية الصافية (تُستخدم كـ Fallback)
  Future<void> _refreshLocalData() async {
    final result = await getAllWalletsLocalUseCase.call();
    result.fold((failure) => print("❌ Local Refresh Failed"), (localWallets) {
      if (localWallets.isNotEmpty) {
        wallets.assignAll(localWallets);
      }
    });
  }

  void runBackgroundSync() {
    syncWalletsUseCase.call().then((result) {
      result.fold((l) => print("⚠️ Sync Error"), (r) => _refreshLocalData());
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
