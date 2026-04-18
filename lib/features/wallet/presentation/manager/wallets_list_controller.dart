import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
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
    loadWallets(isRefresh: true);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (!isLoading.value && hasMore) {
        print("🔗 Scroll reaching end: Requesting page $currentPage");
        loadWallets(isRefresh: false);
      }
    }
  }

  Future<void> loadWallets({bool isRefresh = false}) async {
    if (isLoading.value || (!hasMore && !isRefresh)) return;

    try {
      isLoading.value = true;

      if (isRefresh) {
        print("🔄 Action: Refreshing list...");
        currentPage = 1;
        hasMore = true;
        _runBackgroundSync();
      }

      print("📡 Fetching Data: Page $currentPage, Size $pageSize");
      final result = await getMyWalletsUseCase.call(
        PageRequest(pageNumber: currentPage, pageSize: pageSize),
      );

      result.fold(
        (failure) {
          print("❌ Fetch Failure: ${failure.message}");
          HelperFunction.showSnackBar("تنبيه", failure.message, isError: true);
        },
        (pagedResponse) {
          final newItems = pagedResponse.data;
          print("📦 Received: ${newItems.length} items");

          if (newItems.isEmpty) {
            hasMore = false;
            print("🏁 No more data available on server.");
          } else {
            if (isRefresh) {
              final visibleItems = newItems
                  .where((item) => item.localId != "REMOVE")
                  .toList();
              wallets.assignAll(visibleItems);
            } else {
              final uniqueItems = newItems.where((newItem) {
                bool isNotRemoved = newItem.localId != "REMOVE";
                bool isNotDuplicate = !wallets.any(
                  (existing) => !wallets.any(
                    (existing) =>
                        (existing.walletId != null &&
                            existing.walletId == newItem.walletId) ||
                        (existing.localId == newItem.localId),
                  ),
                );
                return isNotRemoved && isNotDuplicate;
              }).toList();

              wallets.addAll(uniqueItems);
              print("➕ Added ${uniqueItems.length} unique items to list");
            }

            if (newItems.length < pageSize) {
              hasMore = false;
              print("🏁 End of data reached (Last page).");
            } else {
              currentPage++;
            }
          }
          calculateTotals();
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _runBackgroundSync() {
    syncWalletsUseCase.call().then((result) {
      result.fold((l) => print("⚠️ Background Sync Error: ${l.message}"), (r) {
        print("✅ Background Sync Completed");
        _refreshLocalData();
      });
    });
  }

  Future<void> _refreshLocalData() async {
    final result = await getAllWalletsLocalUseCase.call();
    result.fold((failure) => print("❌ Local Refresh Failed"), (localWallets) {
      print("📥 Local Data Reloaded: ${localWallets.length} items");
      wallets.assignAll(localWallets);
      calculateTotals();
    });
  }

  void calculateTotals() {
    totalBalance.value = wallets.fold(
      0.0,
      (sum, wallet) => sum + wallet.balance,
    );
    print("💰 Total Balance Updated: ${totalBalance.value}");
  }

  void resetFields() {
    print("🧹 Resetting Controller fields");
    wallets.clear();
    totalBalance.value = 0.0;
    currentPage = 1;
    hasMore = true;
  }

  @override
  void onClose() {
    print("🔌 Closing WalletsListController");
    scrollController.dispose();
    super.onClose();
  }
}
