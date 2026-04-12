// // تعليق: إعداد التبعيات المشتركة التي يحتاجها التطبيق بالكامل مرة واحدة عند التشغيل
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_usecase.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
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
      ),
      permanent: true, // // تعليق: جعل الكائن دائماً ولا يتم حذفه من الذاكرة
    );

    SignupUsecase.tempUser();
  }
}
