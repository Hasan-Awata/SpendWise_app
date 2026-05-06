// // تعليق: متحكم العمليات المسؤول عن إدارة الأوسمة (إضافة، تعديل، حذف) مع معالجة الأخطاء المتقدمة
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/domain/usecases/add_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/delete_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/update_tag_usecase.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';

class TagActionController extends GetxController {
  final AddTagUsecase addTagUsecase;
  final UpdateTagUsecase updateTagUsecase;
  final DeleteTagUsecase deleteTagUsecase;

  TagActionController({
    required this.addTagUsecase,
    required this.updateTagUsecase,
    required this.deleteTagUsecase,
  });

  final nameController = TextEditingController();
  var isActionLoading = false.obs;

  int? get userId => AppUserLocalDatasourceImpl().currentUserId;

  // // تعليق: إضافة وسم جديد مع التحقق من عدم تكرار الاسم وضمان إدخال بيانات صحيحة
  Future<void> addTag() async {
    final name = nameController.text.trim();

    // 1. التحقق من أن الحقل ليس فارغاً
    if (name.isEmpty) {
      HelperFunction.showSnackBar(
        "تنبيه",
        "يرجى إدخال اسم الوسم أولاً",
        isError: true,
      );
      return;
    }

    // 2. التحقق من عدم تكرار الاسم في القائمة الحالية (Case-insensitive)
    if (Get.isRegistered<TagViewController>()) {
      final isDuplicate = Get.find<TagViewController>().myTags.any(
        (tag) => tag.name.trim().toLowerCase() == name.toLowerCase(),
      );

      if (isDuplicate) {
        HelperFunction.showSnackBar(
          "تنبيه",
          "هذا الوسم موجود بالفعل، يرجى اختيار اسم آخر",
          isError: true,
        );
        return;
      }
    }

    final currentUid = userId; // استخدام الـ getter المعرف مسبقاً
    if (currentUid == null || currentUid == 0) {
      HelperFunction.showSnackBar(
        "تنبيه",
        "فشل الوصول لمعرف المستخدم، يرجى إعادة تسجيل الدخول",
        isError: true,
      );
      return;
    }

    try {
      isActionLoading.value = true;
      final newTag = TagModel(userId: currentUid, name: name, isSynced: false);

      final result = await addTagUsecase.call(newTag);

      result.fold(
        (failure) {
          HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
        },
        (success) {
          nameController.clear();
          // تحديث القائمة فوراً عند النجاح
          if (Get.isRegistered<TagViewController>()) {
            Get.find<TagViewController>().loadTags(isRefresh: true);
          }

          HelperFunction.showSnackBar("نجاح", "تمت إضافة الوسم بنجاح");
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", "حدث خطأ: $e", isError: true);
    } finally {
      isActionLoading.value = false;
    }
  }

  // // تعليق: تحديث بيانات الوسم وإخطار واجهة المستخدم بالتغييرات الحاصلة
  Future<void> updateTag(TagModel tag, String newName) async {
    try {
      isActionLoading.value = true;

      tag.name = newName;

      final result = await updateTagUsecase.call(tag);

      result.fold(
        (failure) =>
            HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
        (success) {
          if (Get.isRegistered<TagViewController>()) {
            Get.find<TagViewController>().loadTags(isRefresh: true);
          }
          HelperFunction.showSnackBar("نجاح", "تم تحديث الوسم");
          if (Get.isOverlaysOpen) Get.back();
        },
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  // // تعليق: حذف الوسم مع مراعاة الحالة المحلية (Offline) وعرض رسالة توضيحية لنوع الحذف (سيرفر/محلي)
  Future<void> deleteTag(TagModel tag) async {
    try {
      // 1. تنفيذ عملية الحذف واستقبال الرسالة التوضيحية من المستودع
      final result = await deleteTagUsecase.call(tag);

      result.fold(
        (failure) => HelperFunction.showSnackBar(
          "خطأ",
          "فشل طلب الحذف: ${failure.message}",
          isError: true,
        ),
        (successMessage) {
          // 2. تحديث قائمة العرض فوراً (UI Update)
          if (Get.isRegistered<TagViewController>()) {
            // نستخدم localId للحذف من القائمة لأنه المرجع الوحيد المضمون محلياً
            Get.find<TagViewController>().myTags.removeWhere(
              (t) => t.localId == tag.localId,
            );

            if (Get.isOverlaysOpen) Get.back();
          }
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar(
        "خطأ",
        "حدث خطأ غير متوقع أثناء محاولة الحذف",
        isError: true,
      );
    }
  }

  @override
  void onClose() {
    // // تعليق: تنظيف الذاكرة وإغلاق متحكم النصوص عند تدمير الكلاس
    nameController.dispose();
    super.onClose();
  }
}
