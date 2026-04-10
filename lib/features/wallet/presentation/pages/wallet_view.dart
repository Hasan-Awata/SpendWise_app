import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/pages/add_wallet_view.dart';

// // تعليق: واجهة عرض المحافظ التي تستخدم Obx لتحديث القائمة تلقائياً عند إضافة أي محفظة جديدة
class WalletsView extends GetView<WalletController> {
  const WalletsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0B121E,
      ), // نفس لون الخلفية الداكن في تصميمك
      appBar: AppBar(
        title: const Text('محافظي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF43C5F3)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.wallets.length,
          itemBuilder: (context, index) {
            final wallet = controller.wallets[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF162030),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "currency",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SAR ${wallet.balance}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF43C5F3),
                    size: 30,
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF43C5F3),
        onPressed: () => Get.to(() => const AddWalletView()),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
