import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository.dart';

class GetUserIdUsecase {
  // // Logic: إنشاء نسخة ثابتة ووحيدة من الكلاس للوصول السريع

  final UserRepository userRepository;
  GetUserIdUsecase(this.userRepository);

  static Future<int> get userId async {
    return AppUserLocalDatasourceImpl().getUserId();
  }

  Future<int> getUserId() async {
    return userRepository.getUserId();
  }
}
