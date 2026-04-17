import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';

class SPAppbar extends StatelessWidget implements PreferredSizeWidget {
  const SPAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,

      title: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "مرحباً، مهند",
                style: TextStyle(
                  color: SpColor.offWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "طاب يومك المالي!",
                style: TextStyle(
                  color: SpColor.offWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () async {
            final user = await AppUserLocalDatasourceImpl().getUser();

            if (user == null) {
              Get.snackbar(
                'No Local User',
                'لا يوجد مستخدم محفوظ محليا',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            print(user.token);
            Get.defaultDialog(
              title: 'Local User Info',
              titleStyle: const TextStyle(color: SpColor.offWhite),
              backgroundColor: SpColor.surfaceNavy,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User ID: ${user.userId}',
                    style: const TextStyle(color: SpColor.offWhite),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'First Name: ${user.firstName ?? '-'}',
                    style: const TextStyle(color: SpColor.offWhite),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Name: ${user.lastName ?? '-'}',
                    style: const TextStyle(color: SpColor.offWhite),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Username: ${user.userName ?? '-'}',
                    style: const TextStyle(color: SpColor.offWhite),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Token: ${user.token.isEmpty ? '-' : user.token}',
                    style: const TextStyle(color: SpColor.offWhite),
                  ),
                ],
              ),
              textConfirm: 'OK',
              confirmTextColor: Colors.white,
              buttonColor: SpColor.accentBlue,
              onConfirm: Get.back,
            );
          },
        ),
      ],
      iconTheme: IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
