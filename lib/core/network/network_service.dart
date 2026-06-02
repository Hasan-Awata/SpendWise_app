import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final http.Client client;

  NetworkService({required this.client});

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final RxBool isOnline = false.obs;
  Timer? _debounceTimer;
  Completer<bool>? _refreshCompleter;

  @override
  void onInit() {
    super.onInit();
    _listenToNetwork();
  }

  // =========================
  // CONNECTIVITY
  // =========================

  void _listenToNetwork() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      // 1. تحقق هل هناك أي نوع اتصال (Wi-Fi أو Mobile)
      final hasNetwork = results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi,
      );

      // 2. إذا فقدنا الشبكة تماماً، اجعلها Offline فوراً
      if (!hasNetwork) {
        isOnline.value = false;
        _debounceTimer?.cancel(); // إلغاء أي فحص جاري
        return;
      }

      // 3. إذا عادت الشبكة، قم بالفحص بدقة
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        final hasRealInternet = await _hasRealInternet();
        isOnline.value = hasRealInternet;
      });
    });
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // هذا هو الـ Getter الذي كان مفقوداً
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    final hasNetwork =
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
    return hasNetwork && await _hasRealInternet();
  }

  // =========================
  // REQUEST LOGIC
  // =========================

  Future<dynamic> request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool retry = true,
  }) async {
    if (!isOnline.value) {
      throw Exception("User is offline. Request blocked.");
    }
    final uri = Uri.parse("${ApiEndpoints.baseUrl}$endpoint").replace(
      queryParameters: queryParameters?.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
    );

    if (kDebugMode) {
      print("\n${"=" * 50}");
      print("🚀 [API REQUEST] $method | $uri");
      if (body != null) print("📦 [BODY]: ${jsonEncode(body)}");
      print("-" * 50);
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${CurrentUser.token}',
      };

      http.Response response = await _sendRequest(method, uri, headers, body);

      if (kDebugMode) {
        print("📥 [API RESPONSE] ${response.statusCode}");
        print("📝 [DATA]: ${response.body}");
        print("=" * 50 + "\n");
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isEmpty ? null : jsonDecode(response.body);
      }

      if (response.statusCode == 401 && retry) {
        final refreshed = await _refreshToken();

        if (refreshed) {
          return await request(
            endpoint: endpoint,
            method: method,
            queryParameters: queryParameters,
            body: body,
            retry: false,
          );
        }

        await _logoutAndGoToLogin();
        throw Exception("Session expired");
      }

      throw Exception("Request failed with status: ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ [API ERROR]: $e");
        print("=" * 50 + "\n");
      }
      rethrow;
    }
  }

  // =========================
  // AUTH & DIALOG
  // =========================
  Future<void> _logoutAndGoToLogin() async {
    try {
      await CurrentUser.clear();
    } catch (_) {}

    Get.offAllNamed('/login');
  }

  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    print(
      "accessToken: ${CurrentUser.token}\n refreshToken: ${CurrentUser.refreshToken}",
    );
    try {
      final response = await client.post(
        Uri.parse("${ApiEndpoints.baseUrl}${ApiEndpoints.refreshToken}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "accessToken": CurrentUser.token,
          "refreshToken": CurrentUser.refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await CurrentUser.save(UserModel.fromJson(data['data'] ?? data));

        _refreshCompleter!.complete(true);
      } else {
        _refreshCompleter!.complete(false);
      }
    } catch (e) {
      _refreshCompleter!.complete(false);
    } finally {
      final completer = _refreshCompleter;
      _refreshCompleter = null;
      return completer!.future;
    }
  }
  // =========================
  // HELPERS
  // =========================

  Future<http.Response> _sendRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final requestClient = client;
    switch (method.toUpperCase()) {
      case 'GET':
        return await requestClient
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 30));
      case 'POST':
        return await requestClient
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 30));
      case 'PATCH':
        return await requestClient
            .patch(uri, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 30));
      case 'DELETE':
        return await requestClient
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 30));
      default:
        throw Exception("Method not supported: $method");
    }
  }

  // =========================
  // FILE UPLOAD
  // =========================

  /// دالة لرفع ملف باستخدام تقنية multipart/form-data
  Future<dynamic> upload({
    required String endpoint,
    required File file,
    String fieldName = 'file',
    bool retry = true,
  }) async {
    // 1. التحقق من الاتصال قبل البدء
    if (!isOnline.value) {
      throw Exception("User is offline. Upload blocked.");
    }

    final uri = Uri.parse("${ApiEndpoints.baseUrl}$endpoint");

    try {
      // 2. إعداد الطلب
      var request = http.MultipartRequest('POST', uri);

      // إضافة التوكن (Authorization)
      request.headers['Authorization'] = 'Bearer ${CurrentUser.token}';

      // إضافة الملف
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        fieldName,
        stream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // 3. إرسال الطلب
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print("📤 [API UPLOAD] ${response.statusCode} ${response.body} | $uri");
      }

      // 4. معالجة النجاح
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isEmpty ? null : jsonDecode(response.body);
      }

      // 5. التعامل مع انتهاء صلاحية التوكن (401)
      if (response.statusCode == 401 && retry) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // إعادة المحاولة مرة واحدة بعد تحديث التوكن
          return await upload(
            endpoint: endpoint,
            file: file,
            fieldName: fieldName,
            retry: false,
          );
        }
        await _logoutAndGoToLogin();
        throw Exception("Session expired");
      }

      throw Exception("Upload failed with status: ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ [API UPLOAD ERROR]: $e");
      }
      rethrow;
    }
  }

  Future<void> _performLogout() async {
    if (Get.isRegistered<AppUserLocalDatasource>()) {
      await Get.find<AppUserLocalDatasource>().logOut();
    }
  }
}
