import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_all_wallets_local_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';

class WalletsListController extends GetxController {
  WalletsListController({
    required this.getMyWalletsUseCase,
    required this.getAllLocalWalletsUseCase,
  });

  final GetMyWalletsUseCase getMyWalletsUseCase;
  final GetAllWalletsLocalUseCase getAllLocalWalletsUseCase;

  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final errorMessage = ''.obs;

  final ScrollController scrollController = ScrollController();
  final currentPage = 1.obs;
  final int pageSize = 20;

  // قفل لمنع استدعاء الدالة أكثر من مرة في نفس الوقت
  bool _isProcessing = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    loadWallets(isRefresh: true);
  }

  void _scrollListener() {
    if (!scrollController.hasClients || _isProcessing) return;

    final position = scrollController.position;
    // التحقق من الوصول للنهاية بمسافة 100 بكسل (أدق من النسبة المئوية)
    if (position.pixels >= position.maxScrollExtent - 100) {
      if (!isLoading.value && !isLoadingMore.value && hasMoreData.value) {
        loadWallets();
      }
    }
  }

  // =========================
  // LOAD
  // =========================

  Future<void> loadWallets({bool isRefresh = false}) async {
    // منع الدخول إذا كان هناك عملية جارية
    if (_isProcessing) return;

    if (!isRefresh && !hasMoreData.value) return;

    _isProcessing = true;
    try {
      errorMessage.value = '';

      if (isRefresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      if (wallets.isEmpty && isRefresh) isLoading.value = true;

      final result = await getMyWalletsUseCase.call(
        PageRequest(pageNumber: currentPage.value, pageSize: pageSize),
      );

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          if (wallets.isEmpty) _loadLocalFallback(isRefresh);
        },
        (pagedResponse) {
          final fetchedItems = pagedResponse.data
              .where((e) => !e.isDeleted)
              .toList();

          if (isRefresh) {
            wallets.assignAll(fetchedItems);
          } else {
            _mergeWallets(fetchedItems);
          }

          // ترتيب نهائي لضمان صحة العرض
          wallets.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );

          // تحديث الصفحة التالية
          if (fetchedItems.length < pageSize) {
            hasMoreData.value = false;
          } else {
            currentPage.value++;
          }
        },
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
      _isProcessing = false; // فتح القفل
    }
  }
  // =========================
  // LOCAL FALLBACK
  // =========================

  Future<void> _loadLocalFallback(bool isRefresh) async {
    final result = await getAllLocalWalletsUseCase.call();

    result.fold((_) {}, (localWallets) {
      final filtered = localWallets.where((e) => !e.isDeleted).toList();

      if (isRefresh) {
        wallets.assignAll(filtered);
      } else {
        _mergeWallets(filtered);
      }

      wallets.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
      HelperFunction.showSnackBar("نجاح", "تمت العملية");
    });
  }

  // =========================
  // SMART MERGE
  // =========================

  void _mergeWallets(List<WalletEntity> newItems) {
    final Set<String> existingIds = wallets.map((e) => e.localId).toSet();
    final List<WalletEntity> uniqueItems = newItems
        .where((item) => !existingIds.contains(item.localId))
        .toList();

    if (uniqueItems.isNotEmpty) {
      wallets.addAll(uniqueItems);
    }
  }

  // =========================
  // LOCAL UI UPDATE
  // =========================

  void addWalletLocally(WalletEntity wallet) {
    wallets.insert(0, wallet);

    wallets.refresh();
  }

  void updateWalletLocally(WalletEntity updatedWallet) {
    final index = wallets.indexWhere((e) => e.localId == updatedWallet.localId);

    if (index == -1) {
      return;
    }

    wallets[index] = updatedWallet;

    wallets.refresh();
  }

  void deleteWalletLocally(String localId) {
    wallets.removeWhere((e) => e.localId == localId);

    wallets.refresh();
  }

  // =========================
  // SYNC
  // =========================

  // Future<void> runBackgroundSync() async {
  //   final result = await syncWalletsUseCase.call();

  //   result.fold((_) {}, (_) async {
  //     await loadWallets(isRefresh: true);
  //   });
  // }

  // =========================
  // REFRESH
  // =========================

  Future<void> refreshWallets() async {
    await loadWallets(isRefresh: true);
  }

  // =========================
  // RETRY
  // =========================

  Future<void> retry() async {
    await loadWallets(isRefresh: true);
  }
}
