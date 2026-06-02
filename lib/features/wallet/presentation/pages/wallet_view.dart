// lib/features/wallet/presentation/pages/wallets_view.dart
// WalletsView: Split view architecture classifying active cash streams from locked savings buffers cleanly

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/presentation/manager/delete_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class WalletsView extends GetView<WalletsListController> {
  const WalletsView({super.key});

  @override
  Widget build(BuildContext context) {
    final deleteController = Get.find<DeleteWalletController>();
    final updateController = Get.find<UpdateWalletController>();

    // استدعاء جلب البيانات المحدثة عند الدخول للشاشة
    controller.refreshWallets();

    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "محافظي المالية",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SpColor.mutedGrey,
        onPressed: () => Get.toNamed('/add-wallet'),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "إضافة محفظة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: SpColor.mutedGrey,
        backgroundColor: const Color(0xFF1E293B),
        onRefresh: () async => await controller.refreshWallets(),
        child: Obx(() {
          // =====================================================
          // LOADING STATE
          // =====================================================
          if (controller.isLoading.value && controller.wallets.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: SpColor.mutedGrey),
            );
          }

          // =====================================================
          // EMPTY STATE
          // =====================================================
          if (controller.wallets.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 220),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white24,
                  size: 80,
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "لا توجد محافظ حالياً",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              ],
            );
          }

          // =====================================================
          // CLASSIFICATION & SPLITTING PIPELINE
          // =====================================================
          final regularWallets = controller.wallets
              .where((w) => !w.isSaved)
              .toList();
          final savingsWallets = controller.wallets
              .where((w) => w.isSaved)
              .toList();

          return ListView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(16),
            children: [
              // القسم الأول: المحافظ الجارية العادية
              if (regularWallets.isNotEmpty) ...[
                _buildSectionHeader(
                  "المحافظ الجارية واليومية",
                  Icons.account_balance_rounded,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: regularWallets.length,
                  itemBuilder: (context, idx) {
                    return _buildWalletCard(
                      deleteController,
                      updateController,
                      regularWallets[idx],
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // القسم الثاني: المحافظ الادخارية والاستثمارية
              if (savingsWallets.isNotEmpty) ...[
                _buildSectionHeader(
                  "الخزائن والمحافظ الادخارية",
                  Icons.savings_rounded,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: savingsWallets.length,
                  itemBuilder: (context, idx) {
                    return _buildWalletCard(
                      deleteController,
                      updateController,
                      savingsWallets[idx],
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // مؤشر جلب المزيد من البيانات للـ Pagination
              if (controller.hasMoreData.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SpColor.mutedGrey,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  // =====================================================
  // SECTION HEADER
  // =====================================================
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12, top: 6),
      child: Row(
        children: [
          Icon(icon, color: SpColor.mutedGrey, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // WALLET CARD WRAPPER
  // =====================================================
  Widget _buildWalletCard(
    DeleteWalletController deleteCtrl,
    UpdateWalletController updateCtrl,
    WalletEntity wallet,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: wallet.isSaved
              ? [
                  const Color(0xFF131C2E),
                  const Color(0xFF0A101D),
                ] // تلميح داكن مائل للأزرق الخزفي للمحافظ الادخارية
              : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        ),
        border: Border.all(
          color: wallet.isSaved
              ? Colors.amber.withOpacity(
                  0.15,
                ) // إطار ذهبي خفيف جداً لإبراز طابع الادخار والخزنة
              : Colors.white12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIcon(wallet.isSaved),
          const SizedBox(width: 16),
          Expanded(child: _buildWalletDetails(wallet)),
          _buildActions(wallet, deleteCtrl, updateCtrl),
        ],
      ),
    );
  }

  // =====================================================
  // ICON WITH TYPE AWARENESS
  // =====================================================
  Widget _buildIcon(bool isSaved) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isSaved
              ? [
                  Colors.amber.shade700,
                  Colors.amber.shade900,
                ] // طابع ذهبي للخزائن الادخارية
              : [SpColor.mutedGrey, SpColor.mutedGrey.withOpacity(0.7)],
        ),
      ),
      child: Icon(
        isSaved ? Icons.savings_rounded : Icons.account_balance_wallet_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // =====================================================
  // DETAILS METRICS WITH LABELS
  // =====================================================
  Widget _buildWalletDetails(WalletEntity wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          wallet.currency.currencyName ?? "Unknown Currency",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          wallet.currency.code ?? "NO Code",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _syncStatusBadge(wallet),
            const SizedBox(width: 6),
            _typeBadge(wallet.isSaved), // وسم توضيحي لنوع المحفظة كتابياً
          ],
        ),
      ],
    );
  }

  Widget _syncStatusBadge(WalletEntity wallet) {
    return Obx(() {
      final bool synced = wallet.isSynced.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: synced
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          synced ? "متزامن" : "غير متزامن",
          style: TextStyle(
            color: synced ? Colors.greenAccent : Colors.orangeAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }

  Widget _typeBadge(bool isSaved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSaved
            ? Colors.amber.withOpacity(0.12)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSaved
              ? Colors.amber.withOpacity(0.2)
              : Colors.blue.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Text(
        isSaved ? "إدخارية" : "جارية",
        style: TextStyle(
          color: isSaved ? Colors.amberAccent : Colors.blueAccent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =====================================================
  // ACTIONS PIPELINES
  // =====================================================
  Widget _buildActions(
    WalletEntity wallet,
    DeleteWalletController deleteCtrl,
    UpdateWalletController updateCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${wallet.balance.toStringAsFixed(2)} ${wallet.currency.code}",
          style: const TextStyle(
            color: SpColor.mutedGrey,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        const SizedBox(width: 6),
        _iconBtn(
          Icons.delete,
          Colors.redAccent,
          () => _showDeleteDialog(wallet, deleteCtrl),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // =====================================================
  // UPDATE DIALOG
  // =====================================================
  // void _showUpdateDialog(WalletEntity wallet, UpdateWalletController ctrl) {
  //   final textController = TextEditingController(
  //     text: wallet.balance.toString(),
  //   );
  //   Get.dialog(
  //     Dialog(
  //       backgroundColor: const Color(0xFF111827),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  //       child: Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               "تعديل رصيد المحفظة",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             TextField(
  //               controller: textController,
  //               keyboardType: TextInputType.number,
  //               style: const TextStyle(color: Colors.white),
  //               decoration: InputDecoration(
  //                 labelText: "الرصيد الجديد",
  //                 labelStyle: const TextStyle(color: Colors.white70),
  //                 filled: true,
  //                 fillColor: Colors.white.withOpacity(0.04),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(14),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 25),
  //             SizedBox(
  //               width: double.infinity,
  //               height: 48,
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: SpColor.mutedGrey,
  //                 ),
  //                 onPressed: () {
  //                   final value = double.tryParse(textController.text);
  //                   if (value != null) {
  //                     wallet.balance = value;
  //                     ctrl.updateWallet(wallet);
  //                   }
  //                   Get.back();
  //                 },
  //                 child: const Text(
  //                   "حفظ التعديلات",
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // =====================================================
  // DELETE DIALOG
  // =====================================================
  void _showDeleteDialog(WalletEntity wallet, DeleteWalletController ctrl) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_forever_rounded,
                color: Colors.redAccent,
                size: 55,
              ),
              const SizedBox(height: 15),
              const Text(
                "حذف المحفظة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "هل أنت متأكد من رغبتك في حذف هذه المحفظة؟",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        "إلغاء",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () {
                        ctrl.deleteWallet(wallet);
                        Get.back();
                      },
                      child: const Text(
                        "حذف",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
