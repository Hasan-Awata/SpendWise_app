// lib/features/wallet/presentation/manager/wallets_list_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';

class WalletsListController extends GetxController {
  final GetMyWalletsUseCase getMyWalletsUseCase;

  WalletsListController({required this.getMyWalletsUseCase});

  // =====================================================
  // STATE
  // =====================================================
  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;

  List<WalletEntity> get regularWallets =>
      wallets.where((w) => !w.isSaved).toList();
  List<WalletEntity> get savingsWallets =>
      wallets.where((w) => w.isSaved).toList();
  final Rxn<WalletEntity> selectWallet = Rxn<WalletEntity>();

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = false.obs;
  final errorMessage = ''.obs;

  final ScrollController scrollController = ScrollController();
  bool _isProcessing = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);

    loadWallets(isRefresh: true);
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;
    if (_isProcessing) return;
    if (!hasMoreData.value) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      if (!isLoading.value && !isLoadingMore.value) {
        loadWallets();
      }
    }
  }

  Future<void> loadWallets({bool isRefresh = false}) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      errorMessage.value = '';
      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoadingMore.value = true;
      }

      if (wallets.isEmpty) {
        isLoading.value = true;
      }

      final result = await getMyWalletsUseCase.call();

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          HelperFunction.showSnackBar("خطأ", failure.message);
        },
        (data) {
          final uniqueData = _sanitize(data);
          wallets.assignAll(uniqueData);

          wallets.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );

          if (wallets.isNotEmpty && selectWallet.value == null) {
            selectWallet.value = wallets.first;
          }

          hasMoreData.value = false;
        },
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
      _isProcessing = false;
    }
  }

  // دالة للتحقق من وجود رصيد كافٍ لعملة محددة عبر جميع محافظ المستخدم
  bool hasSufficientBalance({
    required int currencyId,
    required double requiredAmount,
  }) {
    double totalBalance = 0.0;

    // نجمع رصيد كل المحافظ التي لها نفس عملة المصروف
    for (var wallet in wallets) {
      if (wallet.currencyId == currencyId) {
        totalBalance += wallet.balance;
      }
    }

    // تحقق إذا كان المجموع الكلي يغطي المبلغ المطلوب
    return totalBalance >= requiredAmount;
  }

  List<WalletEntity> _sanitize(List<WalletEntity> list) {
    final Map<String, WalletEntity> map = {};
    for (final item in list) {
      if (item.localId.isNotEmpty) {
        map[item.localId] = item;
      }
    }
    return map.values.toList();
  }

  // =====================================================
  // BALANCE OPERATIONS
  // =====================================================

  Future<void> revertBalance({
    required int walletId,
    required double amountFromRegular,
    required double amountFromSavings,
  }) async {
    final result = await Get.find<WalletRepository>().increaseBalance(
      walletId: walletId,
      amountFromRegular: amountFromRegular,
      amountFromSavings: amountFromSavings,
    );

    result.fold(
      (failure) {
        if (kDebugMode) print("Failed to revert balance: ${failure.message}");
      },
      (success) {
        loadWallets();
      },
    );
  }

  Future<bool> decreaseWalletBalance({
    required int walletId,
    required double amount,
  }) async {
    final result = await Get.find<WalletRepository>().decreaseBalance(
      walletId: walletId,
      amount: amount,
    );

    return result.fold(
      (failure) {
        return false;
      },
      (success) {
        loadWallets();
        return true;
      },
    );
  }

  // الدالة التي كانت مفقودة وتسبب الخطأ في الـ UI
  Future<bool> increaseWalletBalance({
    required int walletId,
    required double amountFromRegular,
    required double amountFromSavings,
  }) async {
    final result = await Get.find<WalletRepository>().increaseBalance(
      walletId: walletId,
      amountFromRegular: amountFromRegular,
      amountFromSavings: amountFromSavings,
    );
    return result.fold(
      (failure) {
        HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
        return false;
      },
      (success) {
        loadWallets();
        return true;
      },
    );
  }

  // =====================================================
  // CRUD & HELPERS
  // =====================================================
  void addWalletLocally(WalletEntity wallet) {
    wallets.insert(0, wallet);
    wallets.refresh();
    if (selectWallet.value == null) selectWallet.value = wallet;
  }

  void updateWalletLocally(WalletEntity wallet) {
    final index = wallets.indexWhere((e) => e.localId == wallet.localId);
    if (index == -1) return;
    wallets[index] = wallet;
    wallets.refresh();
  }

  void deleteWalletLocally(String localId) {
    wallets.removeWhere((e) => e.localId == localId);
    wallets.refresh();
  }

  Future<void> refreshWallets() async {
    await loadWallets(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
