// // تعليق: جلب قائمة المحافظ فقط — الحذف والتعديل في متحكمات منفصلة
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/sync_wallets_usecase.dart';

// // تعليق: متحكم جلب المحافظ - تم إصلاح منطق تحديث القائمة لمنع تكرار العناصر عند إعادة التحميل
class WalletsListController extends GetxController {
  WalletsListController({
    required this.getMyWalletsUseCase,
    required this.syncWalletsUseCase,
  });

  final SyncWalletsUseCase syncWalletsUseCase;
  final GetMyWalletsUseCase getMyWalletsUseCase;
  final wallets = <WalletModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  // // تعليق: دالة تحميل المحافظ المحدثة لضمان استبدال البيانات القديمة ومنع التكرار مع معالجة الأخطاء
  Future<void> loadWallets() async {
    try {
      isLoading.value = true;

      syncWalletsUseCase.call().then((result) {
        result.fold((l) => debugPrint("Background Sync Failed: ${l.message}"), (
          r,
        ) {
          debugPrint("Background Sync Completed Successfully");
          // اختيارياً: يمكنك إعادة جلب البيانات هنا إذا كنت تريد تحديث الـ IDs القادمة من السيرفر
        });
      });

      final result = await getMyWalletsUseCase.call(
        PageRequest(pageNumber: 1, pageSize: 20),
      );

      result.fold(
        (failure) {
          // // ملاحظة: في حال الفشل، الـ Repository الخاص بك مبرمج ليعيد الكاش تلقائياً في حالات معينة
          // // لذا إذا وصلت إلى هنا، فهذا يعني أن الكاش أيضاً قد يكون فارغاً أو تعذر الوصول إليه
          HelperFunction.showSnackBar(
            "تنبيه",
            failure.message, // سيعرض "خطأ في معالجة الكاش" أو "فشل السيرفر"
            isError: true,
          );
        },
        (pagedResponse) {
          // // إصلاح: استخدام assignAll يمسح القائمة القديمة ويضع الجديدة لضمان عدم التكرار
          if (pagedResponse.data.isNotEmpty) {
            wallets.assignAll(pagedResponse.data);
          } else {
            // إذا كانت القائمة فارغة (سواء من السيرفر أو الكاش)
            wallets.clear();
          }
        },
      );
    } catch (e) {
      // معالجة أي خطأ غير متوقع في المتحكم
      HelperFunction.showSnackBar(
        "خطأ",
        "حدث خطأ غير متوقع: $e",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
