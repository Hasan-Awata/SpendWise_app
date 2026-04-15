// // تعليق: حالة المستخدم الحالي وجلب بياناته من التخزين — منفصل عن تسجيل الدخول/الخروج
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/entities/user_entity.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_usecase.dart';

class AuthSessionController extends GetxController {
  AuthSessionController({
    required this.getUserIdUsecase,
    required this.getUserUsecase,
  });

  final GetUserIdUsecase getUserIdUsecase;
  final GetUserUsecase getUserUsecase;

  final Rxn<UserEntity> currentUser = Rxn<UserEntity>();

  static AuthSessionController get instance => Get.find<AuthSessionController>();

  Future<void> getUser() async {
    final result = await getUserUsecase.getUser();
    result.fold((failure) => null, (user) => currentUser.value = user);
  }

  Future<void> fetchUserId() async {
    final result = await getUserIdUsecase.getUserId();
    result.fold((failure) => null, (id) => print("User ID: $id"));
  }

  void clearSession() {
    currentUser.value = null;
  }
}
