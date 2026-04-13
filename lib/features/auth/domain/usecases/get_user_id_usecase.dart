import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/domain/repositories/user_repository.dart';

class GetUserIdUsecase {
  // // Logic: إنشاء نسخة ثابتة ووحيدة من الكلاس للوصول السريع

  final UserRepository userRepository;
  GetUserIdUsecase(this.userRepository);

  static Future<int> get userId async {
    return AppUserLocalDatasourceImpl().getUserId();
  }

  Future<Either<Failure, int>> getUserId() async {
    return userRepository.getUserId();
  }
}
