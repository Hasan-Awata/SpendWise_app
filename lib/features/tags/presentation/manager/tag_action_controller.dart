import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/tags/domain/usecases/add_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/delete_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/update_tag_usecase.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';

class TagActionController extends GetxController {
  TagActionController({
    required this.addTagUsecase,
    required this.updateTagUsecase,
    required this.deleteTagUsecase,
    required this.userIdUsecase,
    required this.tagViewController,
  });

  final AddTagUsecase addTagUsecase;
  final UpdateTagUsecase updateTagUsecase;
  final DeleteTagUsecase deleteTagUsecase;
  final GetUserIdUsecase userIdUsecase;
  final TagViewController tagViewController;

  // =========================
  // STATE
  // =========================

  final nameController = TextEditingController();

  final isLoading = false.obs;

  // =========================
  // ADD
  // =========================

  Future<void> addTag() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      HelperFunction.showSnackBar("تنبيه", "أدخل اسم الوسم", isError: true);
      return;
    }
    if (name[0].isNum) {
      HelperFunction.showSnackBar("تنبيه", "يجب ان يبدأ بحرف", isError: true);
      return;
    }

    try {
      await tagViewController.refreshmyTags();
      isLoading.value = true;

      // =====================
      // USER ID
      // =====================

      int? userId;

      final userResult = await userIdUsecase.getUserId();

      userResult.fold((failure) {
        HelperFunction.showSnackBar("خطأ", "فشل جلب المستخدم", isError: true);
      }, (id) => userId = id);

      if (userId == null) return;

      // =====================
      // ENTITY
      // =====================

      final tag = TagEntity(
        userId: userId!,
        name: name,
        isSynced: false.obs,
        isDeleted: false,
      );

      // =====================
      // OPTIMISTIC UI
      // =====================

      tagViewController.addTagLocally(tag);

      // =====================
      // SAVE
      // =====================

      final result = await addTagUsecase.call(tag);

      result.fold(
        (failure) {
          _handleError("خطأ", failure.message);
        },
        (_) {
          nameController.clear();

          HelperFunction.showSnackBar("نجاح", "تم إضافة الوسم");
        },
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> updateTag(TagEntity tag, String newName) async {
    try {
      if (newName.trim().isEmpty) {
        HelperFunction.showSnackBar("تنبيه", "أدخل اسم الوسم", isError: true);
        return;
      }
      if (newName[0].isNum) {
        HelperFunction.showSnackBar("تنبيه", "يجب ان يبدأ بحرف", isError: true);
        return;
      }
      isLoading.value = true;

      final updated = TagEntity(
        localId: tag.localId,
        id: tag.id,
        userId: tag.userId,
        name: newName,
        isSynced: false.obs,
        isDeleted: false,
      );

      final result = await updateTagUsecase.call(updated);

      result.fold(
        (failure) {
          _handleError("خطأ", failure.message);
        },
        (_) {
          tagViewController.refreshmyTags();

          if (Get.isOverlaysOpen) {
            Get.back();
          }
          HelperFunction.showSnackBar("نجاح", "تم تحديث الوسم");
        },
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deleteTag(TagEntity tag) async {
    try {
      isLoading.value = true;

      // حفظ النسخة للـ rollback
      final backup = tag;

      // =========================
      // OPTIMISTIC DELETE
      // =========================
      tagViewController.deleteTagLocally(tag.localId);

      final result = await deleteTagUsecase.call(tag);

      result.fold((failure) {
        // rollback
        tagViewController.addTagLocally(backup);

        HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
      }, (message) {});
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // ERROR
  // =========================

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
