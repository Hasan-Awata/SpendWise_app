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

    return Scaffold(
      backgroundColor: const Color(0xFF020817),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        centerTitle: true,

        title: const Text(
          "محافظي",
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

        onRefresh: () => controller.refreshWallets(),

        child: Obx(() {
          // =========================
          // LOADING
          // =========================

          if (controller.isLoading.value && controller.wallets.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: SpColor.mutedGrey),
            );
          }

          // =========================
          // EMPTY
          // =========================

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

          // =========================
          // LIST
          // =========================

          return ListView.builder(
            controller: controller.scrollController,

            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            padding: const EdgeInsets.all(16),

            itemCount:
                controller.wallets.length +
                (controller.hasMoreData.value ? 1 : 0),

            itemBuilder: (context, index) {
              if (index < controller.wallets.length) {
                final wallet = controller.wallets[index];

                return _buildWalletCard(
                  wallet,
                  deleteController,
                  updateController,
                );
              }

              return const Padding(
                padding: EdgeInsets.all(20),

                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          );
        }),
      ),
    );
  }

  // =========================
  // WALLET CARD
  // =========================

  Widget _buildWalletCard(
    WalletEntity wallet,
    DeleteWalletController deleteCtrl,
    UpdateWalletController updateCtrl,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),

        border: Border.all(color: Colors.white12),

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
          _buildIcon(),

          const SizedBox(width: 16),

          Expanded(child: _buildWalletDetails(wallet)),

          _buildActions(wallet, deleteCtrl, updateCtrl),
        ],
      ),
    );
  }

  // =========================
  // ICON
  // =========================

  Widget _buildIcon() {
    return Container(
      width: 58,
      height: 58,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        gradient: LinearGradient(
          colors: [SpColor.mutedGrey, SpColor.mutedGrey.withOpacity(0.7)],
        ),
      ),

      child: const Icon(
        Icons.account_balance_wallet_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // =========================
  // DETAILS
  // =========================

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
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          wallet.currency.code ?? "NO Code",

          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),

        const SizedBox(height: 10),

        _syncStatus(wallet.isSynced),
      ],
    );
  }

  // =========================
  // SYNC STATUS
  // =========================

  Widget _syncStatus(bool synced) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: synced
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        synced ? "متزامن" : "غير متزامن",

        style: TextStyle(
          color: synced ? Colors.greenAccent : Colors.orangeAccent,

          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================
  // ACTIONS
  // =========================

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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            _iconBtn(
              Icons.edit,
              Colors.blueAccent,
              () => _showUpdateDialog(wallet, updateCtrl),
            ),

            const SizedBox(width: 6),

            _iconBtn(
              Icons.delete,
              Colors.redAccent,
              () => _showDeleteDialog(wallet, deleteCtrl),
            ),
          ],
        ),
      ],
    );
  }

  // =========================
  // ICON BUTTON
  // =========================

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),

        borderRadius: BorderRadius.circular(12),
      ),

      child: IconButton(
        icon: Icon(icon, color: color, size: 20),

        onPressed: onTap,
      ),
    );
  }

  // =========================
  // UPDATE DIALOG
  // =========================

  void _showUpdateDialog(WalletEntity wallet, UpdateWalletController ctrl) {
    final textController = TextEditingController(
      text: wallet.balance.toString(),
    );

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF111827),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Text(
                "تعديل الرصيد",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: textController,

                keyboardType: TextInputType.number,

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  labelText: "الرصيد الجديد",

                  labelStyle: const TextStyle(color: Colors.white70),

                  filled: true,

                  fillColor: Colors.white.withOpacity(0.04),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpColor.mutedGrey,
                  ),

                  onPressed: () {
                    final value = double.tryParse(textController.text);

                    if (value != null) {
                      wallet.balance = value;

                      ctrl.updateWallet(wallet);
                    }

                    Get.back();
                  },

                  child: const Text(
                    "حفظ التعديلات",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // DELETE DIALOG
  // =========================

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
                Icons.delete_forever,
                color: Colors.redAccent,
                size: 60,
              ),

              const SizedBox(height: 15),

              const Text(
                "حذف المحفظة",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "هل تريد حذف هذه المحفظة؟",

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),

                      child: const Text("إلغاء"),
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
                      },

                      child: const Text("حذف"),
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
