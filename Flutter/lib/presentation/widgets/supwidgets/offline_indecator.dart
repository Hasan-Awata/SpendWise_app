import 'package:flutter/material.dart';

/* يحقق متطلب "دعم العمل دون اتصال بالإنترنت" (Offline Mode) */
class OfflineIndicator extends StatelessWidget {
  final bool isOffline;

  const OfflineIndicator({required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return isOffline
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            color: Colors.orange[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.wifi_off, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  "أنت تعمل الآن دون اتصال - سيتم المزامنة لاحقاً",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}
