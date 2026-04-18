import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/domain/usecases/add_income_usecase.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/presentation/manager/add_tag_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';

class AddIncomeController extends GetxController {
  AddIncomeController({
    required this.addIncomeUseCase,
    required this.walletsListController,
    required this.tagController,
    required this.incomesListController,
    required this.tagActionController,
  });

  final AddIncomeUsecase addIncomeUseCase;
  final WalletsListController walletsListController;
  final TagViewController tagController;
  final TagActionController tagActionController;
  final IncomesListController incomesListController;

  final amountController = TextEditingController();
  final sourceController = TextEditingController();
  final repeatController = TextEditingController();
  final descriptionController = TextEditingController();
  final walletTextController = TextEditingController();
  final tagTextController = TextEditingController();

  final selectedWallet = Rxn<WalletModel>();
  final selectedTag = Rxn<TagModel>();
  final selectedDate = DateTime.now().obs;
  final isLoadingSave = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    walletsListController.loadWallets();
    tagController.loadTags();
  }

  Future<void> saveIncome() async {
    if (!_isInputValid()) return;

    try {
      isLoadingSave.value = true;

      print("selected wallet ${selectedWallet.value.toString()}");

      final TagModel? finalTag = await _handleTagSelection();

      // استبدل السطر الذي يحتوي على الخطأ بهذا المنطق:
      final incomeData = IncomeModel(
        userId:
            AppUserLocalDatasourceImpl().currentUserId ??
            CurrentUser.user!.userId,
        wallet: selectedWallet.value!,
        walletId: selectedWallet.value!.walletId ?? -1,
        incomeTagId: finalTag?.id ?? -1,
        tag:
            finalTag, // مرر الكائن نفسه أيضاً لضمان عدم حدوث خطأ getter 'tag' الذي ظهر لك سابقاً
        description: descriptionController.text.trim(),
        date: selectedDate.value,
        title: sourceController.text.trim().isEmpty
            ? "Untitled Income"
            : sourceController.text.trim(),
        amount: double.parse(amountController.text.trim()),
      );

      final result = await addIncomeUseCase.call(incomeData);

      result.fold(
        (failure) {
          _handleError("فشل الحفظ", failure.message);
        },
        (savedIncome) {
          _onSaveSuccess(savedIncome);
        },
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoadingSave.value = false;
    }
  }

  Future<TagModel?> _handleTagSelection() async {
    final String tagName = tagTextController.text.trim();
    if (tagName.isEmpty) return null;

    final existingTag = tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );
    if (existingTag != null) return existingTag;

    tagActionController.nameController.text = tagName;
    await tagActionController.addTag();

    await tagController.loadTags();
    return tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );
  }

  void _onSaveSuccess(IncomeModel savedIncome) {
    incomesListController.incomesList.insert(0, savedIncome);
    incomesListController.calculateTotals();
    HelperFunction.showSnackBar("تم بنجاح", "تمت إضافة الدخل الجديد");

    resetFields();
  }

  bool _isInputValid() {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty || (double.tryParse(amountText) ?? 0.0) <= 0) {
      _handleError("خطأ في التحقق", "يرجى إدخال مبلغ صحيح أكبر من صفر");
      return false;
    }

    if (selectedWallet.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار محفظة");
      return false;
    }

    return true;
  }

  void resetFields() {
    amountController.clear();
    sourceController.clear();
    descriptionController.clear();
    walletTextController.clear();
    tagTextController.clear();
    selectedDate.value = DateTime.now();
    selectedWallet.value = null;
    selectedTag.value = null;
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  Future<void> fetchDate(BuildContext context) async {
    final picked = await HelperFunction.chooseDate(context);
    if (picked != null) selectedDate.value = picked;
  }

  @override
  void onClose() {
    amountController.dispose();
    sourceController.dispose();
    repeatController.dispose();
    descriptionController.dispose();
    walletTextController.dispose();
    tagTextController.dispose();
    super.onClose();
  }
}
