import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final RxBool isOnline = false.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    _listenToNetwork();
  }

  void _listenToNetwork() {
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      final hasNetwork =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      if (!hasNetwork) {
        isOnline.value = false;

        return;
      }

      _debounceTimer?.cancel();

      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        final realInternet = await _hasRealInternet();

        isOnline.value = realInternet;
      });
    });
  }

  /// تحقق فعلي من الإنترنت (ليس فقط WiFi/Mobile)
  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// فحص يدوي عند الحاجة
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();

    final hasNetwork =
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);

    if (!hasNetwork) return false;

    return await _hasRealInternet();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _debounceTimer?.cancel();
    super.onClose();
  }
}
