import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/tags/domain/usecases/get_my_tags_usecase.dart';

class TagViewController extends GetxController {
  final GetMyTagsUsecase getMyTagsUseCase;

  TagViewController({required this.getMyTagsUseCase});

  // =========================
  // STATE
  // =========================
  final RxList<TagEntity> myTags = <TagEntity>[].obs;

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
    loadTags();
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
        loadTags();
      }
    }
  }

  // =========================
  // LOAD
  // =========================
  Future<void> loadTags({bool isRefresh = false}) async {
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
      if (myTags.isEmpty) isLoading.value = true;

      // استدعاء البيانات (محلي + سيرفر كما عدلنا في الـ Repository)
      final result = await getMyTagsUseCase.call();

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          // HelperFunction.showSnackBar("خطأ", failure.message);
        },
        (data) {
          // [نصيحة داخل الكود]: نقوم بتنظيف البيانات من التكرار بناءً على الـ ID الفريد.
          final uniqueData = _sanitize(data);

          // [نصيحة داخل الكود]: نستخدم assignAll لأن القائمة تأتي كاملة من الـ Local Database.
          myTags.assignAll(uniqueData);

          // ترتيب العناصر حسب تاريخ الإنشاء (الأحدث أولاً)
          myTags.sort(
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
  List<TagEntity> _sanitize(List<TagEntity> list) {
    final Map<String, TagEntity> map = {};

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

  void addTagLocally(TagEntity tag) {
    myTags.insert(0, tag);
    myTags.refresh(); // لضمان تحديث واجهة GetX
  }

  void updateTagLocally(TagEntity tag) {
    final index = myTags.indexWhere((e) => e.localId == tag.localId);
    if (index != -1) {
      myTags[index] = tag;
      myTags.refresh();
    }
  }

  void deleteTagLocally(String localId) {
    myTags.removeWhere((e) => e.localId == localId);
  }

  // =========================
  // REFRESH & RETRY
  // =========================
  Future<void> refreshmyTags() async {
    await loadTags(isRefresh: true);
  }

  Future<void> retry() async {
    await loadTags(isRefresh: true);
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
