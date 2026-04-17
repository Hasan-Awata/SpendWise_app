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
  WalletsListController({
    required this.getMyWalletsUseCase,
    required this.syncWalletsUseCase,
    required this.getAllWalletsLocalUseCase,
  });

  final SyncWalletsUseCase syncWalletsUseCase;
  final GetMyWalletsUseCase getMyWalletsUseCase;
  final GetAllWalletsLocalUseCase getAllWalletsLocalUseCase;

  final wallets = <WalletModel>[].obs;
  final isLoading = false.obs;
  final totalBalance = 0.0.obs;

  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  bool hasMore = true;

  int? userId = AppUserLocalDatasourceImpl().currentUserId;

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

        syncWalletsUseCase.call().then((result) {
          result.fold(
            (l) => debugPrint("Background Sync Failed: ${l.message}"),
            (r) {
              debugPrint("Background Sync Completed Successfully");
              _refreshLocalData();
            },
          );
        });
      }

      final result = await getMyWalletsUseCase.call(
        PageRequest(pageNumber: currentPage, pageSize: 20),
      );

      result.fold(
        (failure) => HelperFunction.showSnackBar(
          "تنبيه",
          failure.message,
          isError: true,
        ),
        (pagedResponse) {
          if (pagedResponse.data.isEmpty) {
            hasMore = false;
          } else {
            if (isRefresh) {
              wallets.assignAll(pagedResponse.data);
            } else {
              final newItems = pagedResponse.data.where((newItem) {
                return !wallets.any(
                  (existing) =>
                      (existing.walletId != null &&
                          existing.walletId == newItem.walletId) ||
                      (existing.localId == newItem.localId),
                );
              }).toList();
              wallets.insertAll(0, newItems);
            }
            currentPage++;
          }
          calculateTotals();
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshLocalData() async {
    final result = await getAllWalletsLocalUseCase.call();
    result.fold((failure) => debugPrint("Local Refresh Failed"), (
      localWallets,
    ) {
      wallets.assignAll(localWallets);
      calculateTotals();
    });
  }

  void calculateTotals() {
    totalBalance.value = wallets.fold(
      0.0,
      (sum, wallet) => sum + wallet.balance,
    );
  }

  void resetFields() {
    wallets.clear();
    totalBalance.value = 0.0;
    currentPage = 1;
    hasMore = true;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
