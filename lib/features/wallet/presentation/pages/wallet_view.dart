// // تعليق: واجهة المحافظ المصلحة بالكامل مع ربط دقيق لعمليات التحديث والحذف بالمتحكمات الخاصة بها
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/presentation/manager/delete_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class WalletsView extends StatelessWidget {
  const WalletsView({super.key});

  @override
  Widget build(BuildContext context) {
    // استدعاء المتحكمات المطلوبة للتأكد من وجودها في الذاكرة
    final listController = Get.find<WalletsListController>();
    final deleteController = Get.find<DeleteWalletController>();
    final updateController = Get.find<UpdateWalletController>();

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
      ),
      body: RefreshIndicator(
        color: const Color(0xFF43C5F3),
        onRefresh: () async => listController.loadWallets(),

        child: Obx(() {
          if (listController.isLoading.value &&
              listController.wallets.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF43C5F3)),
            );
          }

          if (listController.wallets.isEmpty) {
            return ListView(
              controller: listController.scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 300),
                Center(child: _buildEmptyState()),
              ],
            );
          }

          return ListView.builder(
            controller: listController.scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: listController.wallets.length,
            itemBuilder: (context, index) {
              final wallet = listController.wallets[index];
              // إصلاح: تمرير كافة المتحكمات المطلوبة للويدجت الفرعي
              return _buildWalletCard(
                wallet,
                deleteController,
                updateController,
              );
            },
          );
        }),
      ),
    );
  }

  // // تعليق: بناء بطاقة المحفظة مع استقبال متحكمات الحذف والتعديل
  Widget _buildWalletCard(
    WalletModel wallet,
    DeleteWalletController deleteCtrl,
    UpdateWalletController updateCtrl,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162030),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.currency.currencyName,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${wallet.balance} ${wallet.currency.code}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // ربط الأزرار بالعمليات البرمجية
          _buildActionButtons(wallet, deleteCtrl, updateCtrl),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    WalletModel wallet,
    DeleteWalletController deleteCtrl,
    UpdateWalletController updateCtrl,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر التعديل - يفتح حوار التعديل ويمرر متحكم التحديث
        IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.blueGrey),
          onPressed: () => _showUpdateDialog(wallet, updateCtrl),
        ),
        // زر الحذف - يفتح حوار التأكيد ويمرر متحكم الحذف
        IconButton(
          icon: const Icon(
            Icons.delete_sweep_outlined,
            color: Colors.redAccent,
          ),
          onPressed: () => _showDeleteDialog(wallet, deleteCtrl),
        ),
      ],
    );
  }

  // // تعليق: حوار تأكيد الحذف المرتبط بمتحكم الحذف المنفصل
  void _showDeleteDialog(
    WalletModel wallet,
    DeleteWalletController deleteCtrl,
  ) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل تريد حذف محفظة ${wallet.currency.currencyName}؟",
      backgroundColor: const Color(0xFF162030),
      titleStyle: const TextStyle(color: Colors.redAccent),
      middleTextStyle: const TextStyle(color: Colors.white),
      textConfirm: "حذف الآن",
      textCancel: "تراجع",
      confirmTextColor: Colors.white,
      onConfirm: () {
        deleteCtrl.deleteWallet(wallet);
        Get.back();
      },
    );
  }

  // // تعليق: حوار التعديل المرتبط بمتحكم التحديث المصلح سابقاً
  void _showUpdateDialog(
    WalletModel wallet,
    UpdateWalletController updateCtrl,
  ) {
    final amountController = TextEditingController(
      text: wallet.balance.toString(),
    );

    Get.defaultDialog(
      title: "تعديل الرصيد",
      backgroundColor: const Color(0xFF162030),
      titleStyle: const TextStyle(color: Color(0xFF43C5F3)),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: "الرصيد الجديد",
          labelStyle: TextStyle(color: Colors.white54),
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF43C5F3),
        ),
        onPressed: () {
          double? newBalance = double.tryParse(amountController.text);
          if (newBalance != null) {
            // ملاحظة: إذا كان الـ balance حقل final، استخدم دالة copyWith المذكورة سابقاً
            // هنا نفترض أننا نحدث الكائن قبل إرساله للمتحكم
            wallet.balance = newBalance;
            updateCtrl.updateWallet(wallet);
          }
          Get.back();
        },
        child: const Text("حفظ التعديل"),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF43C5F3).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.account_balance_wallet_rounded,
        color: Color(0xFF43C5F3),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("لا توجد محافظ", style: TextStyle(color: Colors.white38)),
    );
  }
}
