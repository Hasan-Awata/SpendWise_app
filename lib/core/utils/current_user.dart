import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

class CurrentUser {
  factory CurrentUser() => CurrentUser._internal();
  CurrentUser._internal();

  static UserModel? currentUser;

  static UserModel? get user => currentUser;

  static Future<bool> get isUserLoggedIn async {
    final loged = await AppUserLocalDatasourceImpl().getUser();
    if (loged == null) {
      return false;
    }
    return true;
  }
}
