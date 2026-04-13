import 'package:hive/hive.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

class AppUserLocalDatasourceImpl extends GetxService
    implements AppUserLocalDatasource {
  static final AppUserLocalDatasourceImpl _instance =
      AppUserLocalDatasourceImpl._internal();
  AppUserLocalDatasourceImpl._internal();
  factory AppUserLocalDatasourceImpl() => _instance;

  static const String _boxName = 'CURRENTUSER';
  static const String _userKey = 'current_user';

  late Box _box;

  int? _cachedUserId;

  @override
  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      // جلب المعرف وتخزينه في الذاكرة فور تشغيل التطبيق
      final user = _box.get(_userKey) as UserModel?;
      _cachedUserId = user?.userId;
    } catch (e) {
      throw Exception("Failed to initialize local storage: $e");
    }
  }

  @override
  Future<void> registerLocal(UserModel user) async {
    try {
      await _box.put(_userKey, user);
    } catch (e) {
      throw Exception("Failed to save user data locally: $e");
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _box.delete(_userKey);
    } catch (e) {
      throw Exception("Failed to clear local user session: $e");
    }
  }

  @override
  Future<UserModel>? getUser() async {
    return await _box.get(_userKey);
  }

  // الآن هذه الدالة سريعة جداً لأنها تعيد القيمة من الذاكرة مباشرة
  @override
  Future<int> getUserId() async {
    if (_cachedUserId != null) {
      return _cachedUserId!;
    }
    // محاولة أخيرة للقراءة من الـ Box إذا كانت الذاكرة فارغة
    final user = await getUser();
    if (user != null) {
      _cachedUserId = user.userId;
      return user.userId!;
    }
    throw Exception("User not found");
  }

  // دالة إضافية للوصول المباشر (Synchronous) بدون await
  int? get currentUserId => _cachedUserId;
}
