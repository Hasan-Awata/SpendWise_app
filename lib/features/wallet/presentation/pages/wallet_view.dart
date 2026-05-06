// // تعليق: واجهة المحافظ المصلحة بالكامل مع ربط دقيق لعمليات التحديث والحذف بالمتحكمات الخاصة بها
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/presentation/manager/delete_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

// // واجهة عرض المحافظ: تستخدم لتمثيل قائمة الحسابات المالية للمستخدم
class WalletsView extends StatefulWidget {
  const WalletsView({super.key});

  @override
  State<WalletsView> createState() => _WalletsViewState();
}

class _WalletsViewState extends State<WalletsView> {
  final listController = Get.find<WalletsListController>();
  final deleteController = Get.find<DeleteWalletController>();
  final updateController = Get.find<UpdateWalletController>();

  @override
  void initState() {
    super.initState();
    listController.loadWallets(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // // استدعاء المتحكمات المطلوبة للتأكد من وجودها في الذاكرة لربط العمليات (الربط، الحذف، التحديث)

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
        color: SpColor.accentBlue,
        backgroundColor: SpColor.surfaceNavy,

        onRefresh: () async => listController.loadWallets(isRefresh: true),

        child: Obx(() {
          // // حالة التحميل: تظهر مؤشر الانتظار إذا كانت القائمة فارغة ويجري جلب البيانات
          if (listController.isLoading.value &&
              listController.wallets.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF43C5F3)),
            );
          }

          // // الحالة الفارغة: تظهر رسالة للمستخدم في حال عدم وجود أي محفظة
          if (listController.wallets.isEmpty) {
            return ListView(
              controller: listController.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 300),
                Center(child: _buildEmptyState()),
              ],
            );
          }

          // // بناء القائمة: عرض المحافظ بشكل ديناميكي عند توفر البيانات
          return ListView.builder(
            controller: listController.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: listController.wallets.length,
            itemBuilder: (context, index) {
              final wallet = listController.wallets[index];
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

  // // تعليق: بناء بطاقة المحفظة التي تعرض تفاصيل الرصيد والعملة وتوفر أزرار التحكم
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
          // // ربط الأزرار بالعمليات البرمجية (تعديل وحذف)
          _buildActionButtons(wallet, deleteCtrl, updateCtrl),
        ],
      ),
    );
  }

  // // ويدجت فرعي لبناء أزرار التحكم داخل البطاقة
  Widget _buildActionButtons(
    WalletModel wallet,
    DeleteWalletController deleteCtrl,
    UpdateWalletController updateCtrl,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // // زر التعديل - يفتح حوار التعديل ويمرر متحكم التحديث لتنفيذ العملية
        IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.blueGrey),
          onPressed: () => _showUpdateDialog(wallet, updateCtrl),
        ),
        // // زر الحذف - يفتح حوار التأكيد ويمرر متحكم الحذف لتنفيذ العملية
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

  // // تعليق: حوار تأكيد الحذف المرتبط بمتحكم الحذف المنفصل لضمان تجربة مستخدم آمنة
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
      },
    );
  }

  // // تعليق: حوار التعديل المرتبط بمتحكم التحديث المصلح لتغيير الرصيد الحالي للمحفظة
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
            // // تحديث قيمة الرصيد في الكائن قبل إرساله للمتحكم للمعالجة
            wallet.balance = newBalance;
            updateCtrl.updateWallet(wallet);
          }
        },
        child: const Text("حفظ التعديل"),
      ),
    );
  }

  // // بناء الأيقونة الجمالية للمحفظة
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

  // // تعليق: واجهة تظهر في حالة عدم وجود أي بيانات لعرضها
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "لا توجد محافظ حالياً",
        style: TextStyle(color: Colors.white38),
      ),
    );
  }
}
