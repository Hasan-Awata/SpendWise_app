// // تعليق: متحكم الأوسمة المطور - يتبنى نفس معايير منطق المحفظة لمنع التكرار وضمان استقرار البيانات
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/domain/usecases/get_my_tags_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/sync_pending_tags_usecase.dart';

class TagViewController extends GetxController {
  TagViewController({
    required this.getMyTagsUsecase,
    required this.syncPendingTagsUsecase,
  });

  final GetMyTagsUsecase getMyTagsUsecase;
  final SyncPendingTagsUsecase syncPendingTagsUsecase;

  final myTags = <TagModel>[].obs;
  final isLoading = false.obs;

  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  bool hasMoreData = true;

  int? userId = AppUserLocalDatasourceImpl().currentUserId;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    // التحديث الأولي عند تشغيل المتحكم
    loadTags(isRefresh: true);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      // التحقق من عدم التحميل حالياً ووجود بيانات إضافية قبل الاستدعاء
      if (!isLoading.value && hasMoreData) {
        loadTags(isRefresh: false);
      }
    }
  }

  // // تعليق: دالة جلب الأوسمة مع دمج منطق التزامن الخلفي والتحقق الذكي من العناصر المكررة
  Future<void> loadTags({bool isRefresh = false}) async {
    // منع الطلبات المتكررة أو عند انتهاء البيانات
    if (isLoading.value || (!hasMoreData && !isRefresh)) return;

    try {
      isLoading.value = true;

      if (isRefresh) {
        currentPage = 1;
        hasMoreData = true;

        // تشغيل التزامن في الخلفية عند التحديث (Refresh) كما في المحفظة
        syncPendingTagsUsecase.call().then((result) {
          result.fold(
            (l) => debugPrint("Background Sync Failed: ${l.message}"),
            (r) => debugPrint("Background Sync Completed Successfully"),
          );
        });
      }

      final result = await getMyTagsUsecase.call(
        PageRequest(pageNumber: currentPage, pageSize: 20),
      );

      result.fold(
        (failure) => HelperFunction.showSnackBar(
          "خطأ في الجلب",
          failure.message,
          isError: true,
        ),
        (pagedResponse) {
          if (pagedResponse.data.isEmpty) {
            hasMoreData = false;
          } else {
            if (isRefresh) {
              myTags.assignAll(pagedResponse.data);
            } else {
              final newItems = pagedResponse.data.where((newItem) {
                return !myTags.any(
                  (existing) =>
                      (existing.id != null && existing.id == newItem.id) ||
                      (existing.localId == newItem.localId),
                );
              }).toList();

              myTags.insertAll(0, newItems);
            }
            currentPage++;
          }
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  // // ميزة Wallet: إعادة تصفير الحقول بشكل كامل
  void resetFields() {
    myTags.clear();
    currentPage = 1;
    hasMoreData = true;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
