// // تعليق: واجهة عرض المحافظ مع دعم ميزة السحب للحذف (Swipe to Delete) والتحديث التلقائي
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';

class WalletsView extends GetView<WalletController> {
  const WalletsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B121E),
      appBar: AppBar(
        title: const Text(
          'محافظي',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.loadWallets(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.wallets.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF43C5F3)),
          );
        }

        if (controller.wallets.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد محافظ حالياً',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.wallets.length,
          itemBuilder: (context, index) {
            final wallet = controller.wallets[index];

            // // تعليق: استخدام Dismissible للسماح بحذف المحفظة عبر السحب لليسار
            return Dismissible(
              key: Key(wallet.walletId.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_sweep,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              onDismissed: (direction) {
                // استدعاء دالة الحذف من الـ Controller
                if (wallet.walletId != null) {
                  controller.deleteWallet(wallet.walletId!);
                }
              },
              child: _buildWalletCard(wallet),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF43C5F3),
        elevation: 5,
        onPressed: () => Get.toNamed('/add-wallet'),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
      ),
    );
  }

  // // تعليق: بناء بطاقة المحفظة بشكل منفصل لتحسين نظافة الكود
  Widget _buildWalletCard(var wallet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF162030),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wallet.currency.currencyName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${wallet.balance}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      wallet.currency.code,
                      style: const TextStyle(
                        color: Color(0xFF43C5F3),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF43C5F3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF43C5F3),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
