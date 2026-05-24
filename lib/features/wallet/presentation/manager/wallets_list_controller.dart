import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';

class WalletsListController extends GetxController {
  final GetMyWalletsUseCase getMyWalletsUseCase;

  WalletsListController({required this.getMyWalletsUseCase});

  // =========================
  // STATE
  // =========================
  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;

  // جعلناها false افتراضياً لأن الـ Repository حالياً يجلب كل البيانات دفعة واحدة
  final hasMoreData = false.obs;
  final errorMessage = ''.obs;

  final ScrollController scrollController = ScrollController();

  // متغير الحماية من الحلقة المفرغة
  bool _isProcessing = false;

  // =========================
  // INIT
  // =========================
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    loadWallets(isRefresh: true);
  }

  // =========================
  // SCROLL
  // =========================
  void _scrollListener() {
    if (!scrollController.hasClients || _isProcessing) return;

    // [نصيحة داخل الكود]: إذا كان لا يوجد بيانات إضافية (Pagination) توقف عن طلب المزيد لمنع التكرار.
    if (!hasMoreData.value) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      if (!isLoading.value && !isLoadingMore.value) {
        loadWallets();
      }
    }
  }

  // =========================
  // LOAD
  // =========================
  Future<void> loadWallets({bool isRefresh = false}) async {
    // 1. حماية صارمة لمنع تداخل الطلبات (سبب الـ Logs المتكررة)
    if (_isProcessing) return;

    _isProcessing = true;

    try {
      errorMessage.value = '';

      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoadingMore.value = true;
      }

      // إظهار حالة التحميل الكلية فقط في المرة الأولى
      if (wallets.isEmpty) isLoading.value = true;

      // استدعاء البيانات (محلي + سيرفر كما عدلنا في الـ Repository)
      final result = await getMyWalletsUseCase.call();

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          HelperFunction.showSnackBar("خطأ", failure.message);
        },
        (data) {
          // [نصيحة داخل الكود]: نقوم بتنظيف البيانات من التكرار بناءً على الـ ID الفريد.
          final uniqueData = _sanitize(data);

          // [نصيحة داخل الكود]: نستخدم assignAll لأن القائمة تأتي كاملة من الـ Local Database.
          wallets.assignAll(uniqueData);

          // ترتيب العناصر حسب تاريخ الإنشاء (الأحدث أولاً)
          wallets.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );

          // [نصيحة داخل الكود]: بما أن الـ API لا يدعم pagination (صفحات) حالياً، نغلق الميزة لمنع الـ Infinite Loop.
          hasMoreData.value = false;
        },
      );
    } finally {
      // إنهاء كافة حالات التحميل
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
      _isProcessing = false;
    }
  }

  // =========================
  // SANITIZE (إزالة التكرار)
  // =========================
  List<WalletEntity> _sanitize(List<WalletEntity> list) {
    final Map<String, WalletEntity> map = {};

    for (final item in list) {
      // [نصيحة داخل الكود]: نستخدم localId كمفتاح فريد لضمان عدم ظهور المحفظة مرتين في القائمة.
      if (item.localId.isNotEmpty) {
        map[item.localId] = item;
      }
    }

    return map.values.toList();
  }

  // =========================
  // OPTIMISTIC UI HELPERS
  // =========================
  // تستخدم لتحديث الواجهة فوراً قبل اكتمال عمليات المزامنة

  void addWalletLocally(WalletEntity wallet) {
    wallets.insert(0, wallet);
    wallets.refresh(); // لضمان تحديث واجهة GetX
  }

  void updateWalletLocally(WalletEntity wallet) {
    final index = wallets.indexWhere((e) => e.localId == wallet.localId);
    if (index != -1) {
      wallets[index] = wallet;
      wallets.refresh();
    }
  }

  void deleteWalletLocally(String localId) {
    wallets.removeWhere((e) => e.localId == localId);
  }

  // =========================
  // REFRESH & RETRY
  // =========================
  Future<void> refreshWallets() async {
    await loadWallets(isRefresh: true);
  }

  Future<void> retry() async {
    await loadWallets(isRefresh: true);
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
