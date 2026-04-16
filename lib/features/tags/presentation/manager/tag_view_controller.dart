// // تعليق: متحكم العرض المصلح لمنع تكرار الأوسمة عند التحديث أو التحميل التدريجي
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/domain/usecases/get_my_tags_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/sync_pending_tags_usecase.dart';

class TagViewController extends GetxController {
  final GetMyTagsUsecase getMyTagsUsecase;
  final SyncPendingTagsUsecase syncPendingTagsUsecase;
  TagViewController({
    required this.getMyTagsUsecase,
    required this.syncPendingTagsUsecase,
  });

  var myTags = <TagModel>[].obs;
  var isLoading = false.obs;

  int currentPage = 1;
  bool hasMoreData = true;

  @override
  void onInit() {
    super.onInit();
    loadTags();
  }

  // // تعليق: جلب الأوسمة مع معالجة منطق التحديث (Refresh) لمنع تكرار العناصر
  Future<void> loadTags({bool isRefresh = false}) async {
    // 1. إذا كان طلب تحديث، نصفر العدادات ونمسح القائمة القديمة
    if (isRefresh) {
      currentPage = 1;
      hasMoreData = true;
    }

    if (!hasMoreData && !isRefresh) return;

    isLoading.value = true;

    syncPendingTagsUsecase.call().then((result) {
      result.fold((l) => debugPrint("Background Sync Failed: ${l.message}"), (
        r,
      ) {
        debugPrint("Background Sync Completed Successfully");
        // اختيارياً: يمكنك إعادة جلب البيانات هنا إذا كنت تريد تحديث الـ IDs القادمة من السيرفر
      });
    });

    final result = await getMyTagsUsecase.call(
      PageRequest(pageNumber: currentPage, pageSize: 20),
    );

    result.fold(
      (failure) {
        HelperFunction.showSnackBar(
          "خطأ في الجلب",
          failure.message,
          isError: true,
        );
      },
      (pagedResponse) {
        // 2. إصلاح التكرار: إذا كان ريفريش، استبدل القائمة بالكامل بدل الإضافة عليها
        if (isRefresh) {
          myTags.assignAll(pagedResponse.data);
        } else {
          // في حالة التحميل التدريجي، أضف العناصر الجديدة فقط
          myTags.insertAll(0, pagedResponse.data);
        }

        // 3. تحديث منطق الصفحة القادمة
        if (pagedResponse.data.length < 20) {
          hasMoreData = false;
        } else {
          currentPage++;
        }
      },
    );
    isLoading.value = false;
  }
}
