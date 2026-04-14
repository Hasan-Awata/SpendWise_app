import 'package:get/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService extends GetxService {
  late SharedPreferences _prefs;

  Future<SharedPreferencesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('is_logged_in', value);
  }

  bool get isLoggedIn => _prefs.getBool('is_logged_in') ?? false;

  Future<void> setToken(String value) async {
    await _prefs.setString('token', value);
  }

  String get token => _prefs.getString('token') ?? "no Token";

  Future<void> clear() async {
    await _prefs.clear();
  }
}
