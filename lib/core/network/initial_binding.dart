// // تعليق: إعداد التبعيات المشتركة التي يحتاجها التطبيق بالكامل مرة واحدة عند التشغيل
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/features/auth/presentation/bindings/auth_binding.dart';
import 'package:spendwise/features/income/presentation/bindings/income_binding.dart';
import 'package:spendwise/features/tags/presentation/bindings/tag_binding.dart';
import 'package:spendwise/features/wallet/presentation/bindings/wallet_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final prefs = Get.find<SharedPreferencesService>();
    final token = prefs.token;
    print(token);
    if (!Get.isRegistered<Dio>()) {
      Get.put<Dio>(
        Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) async {
                final prefs = Get.find<SharedPreferencesService>();
                final token = prefs.token;
                options.headers['Authorization'] = 'Bearer $token';
                return handler.next(options);
              },
              onError: (DioException e, handler) {
                // // تعليق: معالجة الأخطاء الشائعة مثل انتهاء صلاحية التوكن (401)
                if (e.response?.statusCode == 401) {
                  // منطق تسجيل الخروج أو تجديد التوكن
                }
                return handler.next(e);
              },
            ),
          ),
        permanent: true,
      );
    }

    AuthBinding(permanentAuthController: true).dependencies();
    WalletBinding().dependencies();
    TagBinding().dependencies();
    IncomeBinding().dependencies();
  }
}
