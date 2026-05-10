import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/tags/domain/usecases/get_my_tags_usecase.dart';

// tag_view_controller.dart

class TagViewController extends GetxController {
  final GetMyTagsUsecase getMyTagsUsecase;

  TagViewController({required this.getMyTagsUsecase});

  final RxList<TagEntity> myTags = <TagEntity>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final errorMessage = ''.obs;

  int page = 1;
  final int pageSize = 20;
  bool _isRequestRunning = false;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadTags(refresh: true);
  }

  void _onScroll() {
    if (!scrollController.hasClients || _isRequestRunning) return;

    // التحميل المبكر قبل الوصول للنهاية بـ 200 بكسل
    if (scrollController.position.extentAfter < 200 && hasMoreData.value) {
      loadTags(refresh: false);
    }
  }

  Future<void> loadTags({required bool refresh}) async {
    if (_isRequestRunning) return;
    _isRequestRunning = true;

    try {
      errorMessage.value = '';

      if (refresh) {
        isRefreshing.value = true;
        page = 1;
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      if (myTags.isEmpty && refresh) isLoading.value = true;

      final result = await getMyTagsUsecase.call(
        PageRequest(pageNumber: page, pageSize: pageSize),
      );

      result.fold((failure) => errorMessage.value = failure.message, (
        response,
      ) {
        final newItems = response.data;

        if (refresh) {
          myTags.assignAll(newItems);
        } else {
          // منع التكرار بكفاءة عالية
          final existingIds = myTags.map((e) => e.localId).toSet();
          final uniqueItems = newItems.where(
            (tag) => !existingIds.contains(tag.localId),
          );
          myTags.addAll(uniqueItems);
        }

        // ترتيب البيانات: الأحدث (الذي يملك ID أكبر أو تاريخ أحدث) في الأعلى
        myTags.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

        if (newItems.length < pageSize) {
          hasMoreData.value = false;
        } else {
          page++;
        }
      });
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
      _isRequestRunning = false;
    }
  }

  void addTagLocally(TagEntity tag) {
    myTags.insert(0, tag);
    myTags.refresh();
  }

  void deleteTagLocally(String localId) {
    myTags.removeWhere((e) => e.localId == localId);
    myTags.refresh();
  }

  Future<void> refreshTags() async {
    await loadTags(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
