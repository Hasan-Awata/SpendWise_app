import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/domain/usecases/delete_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/update_income_usecase.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_controller.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';
import '../../domain/usecases/add_income_usecase.dart';
import '../../domain/usecases/get_all_local_incomes_usecase.dart';
import '../../domain/usecases/get_incomes_usecase.dart';

class IncomeController extends GetxController {
  final AddIncomeUsecase addIncomeUseCase;
  final GetIncomesUsecase getIncomesUseCase;
  final GetAllLocalIncomesUsecase getAllLocalIncomesUsecase;
  final UpdateIncomeUseCase updateIncomeUseCase;
  final DeleteIncomeUseCase deleteIncomeUseCase;
  final WalletController walletController;
  final TagController tagController;

  IncomeController({
    required this.addIncomeUseCase,
    required this.getIncomesUseCase,
    required this.getAllLocalIncomesUsecase,
    required this.updateIncomeUseCase,
    required this.deleteIncomeUseCase,
    required this.walletController,
    required this.tagController,
  });

  // === Controllers ===
  final amountController = TextEditingController();
  final sourceController = TextEditingController();
  final repeatController = TextEditingController();
  final descriptionController = TextEditingController();
  final walletTextController = TextEditingController();
  final tagTextController = TextEditingController();

  // === Reactive States ===
  final Rxn<WalletModel> selectedWallet = Rxn<WalletModel>();
  final Rxn<TagModel> selectedTag = Rxn<TagModel>();
  final RxList<IncomeModel> incomesList = <IncomeModel>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );

  final RxDouble monthlyIncomeTotal = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSave = false.obs;
  final RxBool isLoadingUpdate = false.obs;
  final RxBool isLoadingDelete = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  final ScrollController scrollController = ScrollController();
  int? userId = AppUserLocalDatasourceImpl().currentUserId;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchAllIncomes();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      fetchAllIncomes();
    }
  }

  // === Data Fetching (Pagination & Either Logic) ===
  Future<void> fetchAllIncomes({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || (isLoading.value && !isRefresh)) return;

    isLoading.value = true;
    final pageRequest = PageRequest(
      pageNumber: currentPage.value,
      pageSize: 10,
    );

    // استخدام fold لمعالجة النتيجة القادمة من الـ Repository
    final result = await getIncomesUseCase.call(userId, pageRequest);

    result.fold((failure) => _handleError("خطأ في التحميل", failure.message), (
      pagedResponse,
    ) {
      if (isRefresh) incomesList.clear();

      incomesList.addAll(pagedResponse.data);

      // التحقق من وجود المزيد من البيانات بناءً على توفر صفحات أخرى
      if (currentPage.value >= pagedResponse.totalPages) {
        hasMoreData.value = false;
      } else {
        currentPage.value++;
      }
    });

    isLoading.value = false;
    refreshMonthlyIncomeTotal();
  }

  // === Save Logic ===
  Future<void> saveIncome() async {
    if (!_isInputValid()) return;

    isLoadingSave.value = true;

    final String tagName = tagTextController.text.trim();
    var foundTag = tagController.myTags.firstWhereOrNull(
      (t) => t.name == tagName,
    );

    if (foundTag == null && tagName.isNotEmpty) {
      tagController.tag.value = TagModel(userId: userId ?? 0, name: tagName);
      await tagController.addtag();
      foundTag = tagController.myTags.firstWhereOrNull(
        (t) => t.name == tagName,
      );
    }

    final incomeData = IncomeModel(
      userId: userId,
      wallet: selectedWallet.value!,
      tag: foundTag ?? selectedTag.value,
      description: descriptionController.text.trim(),
      date: selectedDate.value,
      title: sourceController.text.isEmpty
          ? "Untitled Income"
          : sourceController.text.trim(),
      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
    );

    final result = await addIncomeUseCase.call(incomeData);

    result.fold((failure) => _handleError("فشل الحفظ", failure.message), (_) {
      incomesList.insert(0, incomeData);
      refreshMonthlyIncomeTotal();
      HelperFunction.showSnackBar("تم بنجاح", "تمت إضافة الدخل الجديد");
      resetFields();
    });
    isLoadingSave.value = false;
  }

  // === Update Logic ===
  Future<void> updateIncome(int incomeId, IncomeModel updatedData) async {
    isLoadingUpdate.value = true;
    final result = await updateIncomeUseCase.call(incomeId, updatedData);

    result.fold((failure) => _handleError("فشل التحديث", failure.message), (_) {
      int index = incomesList.indexWhere((e) => e.id == incomeId);
      if (index != -1) incomesList[index] = updatedData;
      refreshMonthlyIncomeTotal();
      HelperFunction.showSnackBar("تم بنجاح", "تم تحديث البيانات");
    });
    isLoadingUpdate.value = false;
  }

  // === Delete Logic ===
  Future<void> deleteIncome(int incomeId) async {
    isLoadingDelete.value = true;
    final result = await deleteIncomeUseCase.call(incomeId);

    result.fold((failure) => _handleError("فشل الحذف", failure.message), (_) {
      incomesList.removeWhere((e) => e.id == incomeId);
      refreshMonthlyIncomeTotal();
      HelperFunction.showSnackBar("محذوف", "تم حذف السجل بنجاح");
    });
    isLoadingDelete.value = false;
  }

  // === Dashboard Helpers ===
  Future<void> refreshMonthlyIncomeTotal() async {
    final result = await getAllLocalIncomesUsecase.call();
    result.fold((_) => monthlyIncomeTotal.value = 0.0, (all) {
      final year = dashboardMonth.value.year;
      final month = dashboardMonth.value.month;
      monthlyIncomeTotal.value = all
          .where((e) => e.date.year == year && e.date.month == month)
          .fold<double>(0, (sum, e) => sum + e.amount);
    });
  }

  // === Validation & Utilities ===
  bool _isInputValid() {
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      _handleError("خطأ في التحقق", "يرجى إدخال مبلغ صحيح");
      return false;
    }

    // البحث عن المحفظة المختارة بناءً على النص في الـ Dropdown
    final walletName = walletTextController.text.trim();
    selectedWallet.value = walletController.wallets.firstWhereOrNull(
      (w) =>
          "${w.currency.currencyName}      (${w.currency.code} ${w.balance})"
              .trim() ==
          walletName,
    );
    if (userId == null) {
      _handleError("Faild", "No User id");
      return false;
    }
    if (selectedWallet.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار محفظة صحيحة");
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

  Future<void> pickDashboardMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dashboardMonth.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dashboardMonth.value = DateTime(picked.year, picked.month, 1);
      await refreshMonthlyIncomeTotal();
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    sourceController.dispose();
    repeatController.dispose();
    descriptionController.dispose();
    walletTextController.dispose();
    tagTextController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
