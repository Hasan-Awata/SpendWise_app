// // تعليق: تسجيل الخروج فقط
import 'package:get/get.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/features/auth/domain/usecases/logout_usecase.dart';
import 'package:spendwise/features/auth/presentation/manager/auth_session_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class LogoutController extends GetxController {
  LogoutController({required this.logoutUsecase});

  final LogoutUsecase logoutUsecase;

  final isLoadingLogOut = false.obs;

  Future<void> logOut() async {
    isLoadingLogOut.value = true;

    final result = await logoutUsecase.logout();

    await result.fold(
      (failure) async => HelperFunction.showSnackBar(
        "Logout Failed",
        failure.message,
        isError: true,
      ),
      (_) async {
        final prefs = Get.find<SharedPreferencesService>();
        await prefs.setLoggedIn(false);
        await prefs.setToken('');
        Get.find<AuthSessionController>().clearSession();
        HelperFunction.showSnackBar("Success", "Logged out successfully");
        Get.offAllNamed('/login');
      },
    );

    isLoadingLogOut.value = false;
  }
}
