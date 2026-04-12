import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/domain/usecases/delete_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/update_income_usecase.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_controller.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';
import '../../domain/usecases/add_income_usecase.dart';
import '../../domain/usecases/get_incomes_usecase.dart';

class IncomeController extends GetxController {
  final AddIncomeUsecase addIncomeUseCase;
  final GetIncomesUsecase getIncomesUseCase;
  final UpdateIncomeUseCase updateIncomeUseCase;
  final DeleteIncomeUseCase deleteIncomeUseCase;
  final WalletController walletController;
  final TagController tagController;

  IncomeController({
    required this.addIncomeUseCase,
    required this.getIncomesUseCase,
    required this.updateIncomeUseCase,
    required this.deleteIncomeUseCase,
    required this.walletController,
    required this.tagController,
  });

  // // Form Controllers (Standard Fields)
  final TextEditingController amountController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController repeatController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController walletTextController = TextEditingController();
  final TextEditingController tagTextController = TextEditingController();

  // // Reactive State Variables
  final Rxn<WalletModel> selectedWallet = Rxn<WalletModel>();
  final Rxn<TagModel> selectedTag = Rxn<TagModel>();
  final RxList<IncomeModel> incomesList = <IncomeModel>[].obs;

  final RxString newTagName = "".obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSave = false.obs;
  final RxBool isLoadingUpdate = false.obs;
  final RxBool isLoadingDelete = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  int? userId = AppUserLocalDatasourceImpl().currentUserId;
  final ScrollController scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        fetchAllIncomes();
      }
    });
    fetchAllIncomes();
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

  // // Data Fetching
  Future<void> fetchAllIncomes({bool isRefresh = false}) async {
    // إذا كان المستخدم يسحب الشاشة للأعلى (Refresh)، نبدأ من الصفحة 1
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      incomesList.clear(); // نمسح القائمة القديمة
    }
    // إذا لم يكن هناك بيانات إضافية أو كنا نحمل بالفعل، نوقف العملية
    if (!hasMoreData.value || (isLoading.value && !isRefresh)) return;
    isLoading.value = true;
    try {
      PageRequest page = PageRequest(
        pageNumber: currentPage.value,
        pageSize: 10,
      );
      final results = await getIncomesUseCase.call(userId, page);
      if (results.isEmpty) {
        hasMoreData.value = false;
      } else {
        if (isRefresh) {
          incomesList.assignAll(results);
        } else {
          incomesList.addAll(results);
        }
        incomesList.refresh();
        currentPage.value++;
      }
    } catch (e) {
      _handleError("Load Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearAllIncomes() async {
    await IncomeLocalDataSourceImpl().clear();
    incomesList.clear();
    hasMoreData.value = true;
    currentPage.value = 1;
    refreshIndicatorKey.currentState?.show();
  }

  // // Date Picker
  Future<void> fetchDate(BuildContext context) async {
    final DateTime? pickedDate = await HelperFunction.chooseDate(Get.context!);
    if (pickedDate != null && pickedDate != selectedDate.value) {
      selectedDate.value = pickedDate;
    }
  }

  // // Save Income
  Future<void> saveIncome() async {
    if (!_isInputValid()) return;
    final String tagName = tagTextController.text.trim();
    var foundTag = tagController.myTags.firstWhereOrNull(
      (t) => t.name == tagName,
    );

    final String walletName = walletTextController.text.trim();

    var foundWallet = walletController.wallets.firstWhereOrNull(
      (w) => w.currency.currencyName == walletName,
    );

    selectedWallet.value = foundWallet;
    isLoadingSave.value = true;
    try {
      if (foundTag == null && tagName.isNotEmpty) {
        tagController.tag.value = TagModel(userId: 0, name: tagName);
        await tagController.addtag();
        // بعد الإضافة، نسحب الكائن الجديد لربطه بالدخل
        foundTag = tagController.myTags.firstWhereOrNull(
          (t) => t.name == tagName,
        );
      }

      final double amount =
          double.tryParse(amountController.text.trim()) ?? 0.0;
      final incomeData = IncomeModel(
        wallet: selectedWallet.value,
        tag: selectedTag.value,
        description: descriptionController.text.trim(),
        date: selectedDate.value,
        title: sourceController.text.isEmpty
            ? "Untitled Income"
            : sourceController.text.trim(),
        amount: amount,
      );

      await addIncomeUseCase(incomeData);
      incomesList.insert(0, incomeData);

      HelperFunction.showSnackBar(
        "Success",
        "Income added successfully",
        isError: false,
      );
      // _resetFields();
    } catch (e) {
      _handleError("Save Failed", e.toString());
    } finally {
      isLoadingSave.value = false;
    }
  }

  Future<void> updateIncome(int incomeId, IncomeModel updatedData) async {
    isLoadingUpdate.value = true;
    try {
      await updateIncomeUseCase(incomeId, updatedData);

      // تحديث العنصر في القائمة المحلية فوراً
      int index = incomesList.indexWhere((element) => element.id == incomeId);
      if (index != -1) {
        incomesList[index] = updatedData;
      }

      HelperFunction.showSnackBar(
        "Success",
        "Income updated successfully",
        isError: false,
      );
    } catch (e) {
      _handleError("Update Failed", e.toString());
    } finally {
      isLoadingUpdate.value = false;
    }
  }

  // // Delete Income
  Future<void> deleteIncome(int incomeId) async {
    isLoadingDelete.value = true;
    try {
      await deleteIncomeUseCase(incomeId);

      // حذف العنصر من القائمة المحلية فوراً لتحديث الواجهة
      incomesList.removeWhere((element) => element.id == incomeId);

      HelperFunction.showSnackBar(
        "Deleted",
        "Income removed successfully",
        isError: false,
      );
    } catch (e) {
      _handleError("Delete Failed", e.toString());
    } finally {
      isLoadingDelete.value = false;
    }
  }

  // // Validation
  bool _isInputValid() {
    final double amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      _handleError("Validation Error", "Please enter a valid amount.");
      return false;
    }
    var foundWallet = walletController.wallets.firstWhereOrNull(
      (w) => w.currency.currencyName == walletTextController.text,
    );
    if (foundWallet == null) {
      _handleError("Error", "Not wallet in this name");
      return false;
    }

    if (selectedTag.value == null && tagTextController.text.isEmpty) {
      _handleError("Validation Error", "Please select or type a tag.");
      return false;
    }
    return true;
  }

  void _resetFields() {
    amountController.clear();
    sourceController.clear();
    repeatController.clear();
    descriptionController.clear();
    walletTextController.clear();
    tagTextController.clear();
    newTagName.value = "";
    selectedTag.value = null;
    selectedWallet.value = null;
    selectedDate.value = DateTime.now();
    tagController.myTags.clear();
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
