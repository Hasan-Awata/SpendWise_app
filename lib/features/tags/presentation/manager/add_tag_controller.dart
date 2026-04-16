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
  Future<void> addTag() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    print("Step 1: Start addTag with name: $name"); // للتأكد من بدء الدالة

    final currentUid = AppUserLocalDatasourceImpl().currentUserId;
    print("Step 2: UserID retrieved: $currentUid");

    if (currentUid == null || currentUid == 0) {
      HelperFunction.showSnackBar(
        "تنبيه",
        "فشل الوصول لمعرف المستخدم",
        isError: true,
      );
      return;
    }

    try {
      isActionLoading.value = true;
      final newTag = TagModel(userId: currentUid, name: name, isSynced: false);

      print("Step 3: Calling Usecase...");
      final result = await addTagUsecase
          .call(newTag)
          .timeout(
            const Duration(seconds: 10), // إضافة مهلة زمنية لمنع التعليق
            onTimeout: () => throw "Request Timeout",
          );

      print("Step 4: Result received");

      result.fold(
        (failure) {
          print("Step 5: Failure - ${failure.message}");
          HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
        },
        (success) {
          print("Step 5: Success");
          nameController.clear();
          if (Get.isRegistered<TagViewController>()) {
            Get.find<TagViewController>().loadTags(isRefresh: true);
          }
          HelperFunction.showSnackBar("نجاح", "تمت إضافة الوسم بنجاح");
        },
      );
    } catch (e) {
      print("Step 6: Exception caught - $e");
      HelperFunction.showSnackBar("خطأ", "حدث خطأ: $e", isError: true);
    } finally {
      isActionLoading.value = false;
      print("Step 7: Loading finished");
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
        },
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  // // تعليق: حذف الوسم مع مراعاة الحالة المحلية (Offline) باستخدام localId لضمان دقة التحديث في الواجهة
  Future<void> deleteTag(TagModel tag) async {
    try {
      // 1. تنفيذ عملية الحذف عبر الـ Usecase (التي بدورها ستسمه بـ REMOVE في المستودع)
      final result = await deleteTagUsecase.call(tag);

      result.fold(
        (failure) => HelperFunction.showSnackBar(
          "خطأ",
          "فشل طلب الحذف: ${failure.message}",
          isError: true,
        ),
        (success) {
          // 2. تحديث قائمة العرض فوراً (UI Update)
          if (Get.isRegistered<TagViewController>()) {
            // نستخدم localId للحذف من القائمة لأنه المرجع الوحيد المضمون محلياً
            Get.find<TagViewController>().myTags.removeWhere(
              (t) => t.localId == tag.localId,
            );

            // اختياري: إظهار رسالة تأكيد للمستخدم
            HelperFunction.showSnackBar("نجاح", "تم حذف الوسم بنجاح");
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
