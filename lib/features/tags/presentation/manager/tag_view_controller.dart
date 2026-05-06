import 'package:flutter/widgets.dart';
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

  final myTags = <TagModel>[].obs;
  final isLoading = false.obs;
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  bool hasMoreData = true;
  final int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    loadTags(isRefresh: true);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (!isLoading.value && hasMoreData) {
        print("🔗 Scroll reaching end: Requesting Tags page $currentPage");
        loadTags(isRefresh: false);
      }
    }
  }

  Future<void> loadTags({bool isRefresh = false}) async {
    if (isLoading.value || (!hasMoreData && !isRefresh)) return;
    try {
      isLoading.value = true;

      if (isRefresh) {
        print("🔄 Action: Refreshing Tags list...");
        currentPage = 1;
        hasMoreData = true;
      }

      print("📡 Fetching Tags: Page $currentPage, Size $pageSize");
      final result = await getMyTagsUsecase.call(
        PageRequest(pageNumber: currentPage, pageSize: pageSize),
      );

      result.fold(
        (failure) {
          print("❌ Tags Fetch Failure: ${failure.message}");
          HelperFunction.showSnackBar(
            "خطأ في الجلب",
            failure.message,
            isError: true,
          );
        },
        (pagedResponse) {
          final newItems = pagedResponse.data;
          print("📦 Received: ${newItems.length} Tags");

          if (newItems.isEmpty) {
            hasMoreData = false;
            print("🏁 No more Tags found on server.");
          } else {
            if (isRefresh) {
              // تصفية العناصر المحذوفة محلياً قبل العرض
              final visibleItems = newItems
                  .where((t) => t.localId != "REMOVE")
                  .toList();
              myTags.assignAll(visibleItems);
            } else {
              // تصفية المحذوفات + التكرار ثم الإضافة في نهاية القائمة
              final uniqueAndVisible = newItems.where((newItem) {
                bool isNotRemoved = newItem.localId != "REMOVE";
                bool isNotDuplicate = !myTags.any(
                  (existing) =>
                      (existing.id != null && existing.id == newItem.id) ||
                      (existing.localId == newItem.localId),
                );
                return isNotRemoved && isNotDuplicate;
              }).toList();

              myTags.assignAll(uniqueAndVisible);
              print("➕ Added ${uniqueAndVisible.length} unique Tags to list");
            }

            // تحديث حالة "هل يوجد المزيد"
            if (newItems.length < pageSize) {
              hasMoreData = false;
              print("🏁 End of Tags reached.");
            } else {
              currentPage++;
            }
          }
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  void runBackgroundSync() {
    syncPendingTagsUsecase.call().then((result) {
      result.fold(
        (l) => print("⚠️ Tag Background Sync Failed: ${l.message}"),
        (r) => print("✅ Tag Background Sync Completed Successfully"),
      );
    });
  }

  void resetFields() {
    print("🧹 Resetting Tag fields");
    myTags.clear();
    currentPage = 1;
    hasMoreData = true;
  }

  @override
  void onClose() {
    print("🔌 Closing TagViewController");
    scrollController.dispose();
    super.onClose();
  }
}
