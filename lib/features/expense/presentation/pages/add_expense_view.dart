// تعليق: واجهة إضافة مصروف - مدمجة مع نظام المزامنة والتحقق المطور
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/manager/add_expense_controller.dart';
import 'package:spendwise/features/expense/presentation/widgets/tag_widget.dart';

import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field_description.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

// هذه الفئة تمثل شاشة إضافة مصروف جديد وتدير التفاعل مع المستخدم
class AddExpenseView extends StatefulWidget {
  AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final controller = Get.find<AddExpenseController>();

  final RxBool isFixed = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: const Color(0xFFF15A5A),
        onRefresh: () async {
          // إعادة تعيين الحقول وتحديث البيانات من المستودع
          controller.resetFields();
          await controller.walletsListController.loadWallets();
          await controller.tagController.loadTags();
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // واجهة المستخدم: حقل العنوان (الاسم أو المصدر)
                  _buildField(
                    "عنوان المصروف", // Expense Title
                    controller.titleTextController,
                    Icons.title,
                    hint: "مثال: بقالة، إيجار...", // e.g. Grocery, Rent...
                  ),
                  const SizedBox(height: 20),

                  // واجهة المستخدم: حقل المبلغ
                  _buildField(
                    "المبلغ (ريال)", // Amount (SAR)
                    controller.amountController,
                    Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),

                  // واجهة المستخدم: اختيار الفئة
                  _buildCategoryDropdown(),

                  const SizedBox(height: 25),
                  _buildFixedToggle(),
                  const SizedBox(height: 15),
                  _buildRepetitionField(),

                  const SizedBox(height: 25),
                  CustomTextFieldDescription(
                    label: "الوصف", // Description
                    hint: "تفاصيل المصروف...", // Expense details...
                    textEditingController: controller.descriptionController,
                    textColor: const Color(0xFFF15A5A),
                  ),

                  const SizedBox(height: 25),
                  _buildDatePicker(context),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 30),

                  _buildWalletDropdown(),
                  const SizedBox(height: 25),

                  // واجهة المستخدم: حقل التاج (يدعم الكتابة لإنشاء تاج جديد تلقائياً)
                  _buildTagDropdown(),
                  const SizedBox(height: 15),
                  _buildTagPreview(),

                  const SizedBox(height: 50),
                  _buildSubmitButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- عناصر الواجهة (Widgets) ---

  // إنشاء شريط التطبيق العلوي
  PreferredSizeWidget _buildAppBar() => AppBar(
    title: const Text(
      "مصروف جديد", // New Expense
      style: TextStyle(color: Color(0xFFF15A5A), fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.transparent,
    foregroundColor: const Color(0xFFF15A5A),
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: () => Get.toNamed(Routes.LIST_EXPENSE),
        icon: const Icon(Icons.list),
      ),
    ],
  );

  // بناء حقل إدخال نصي مخصص
  Widget _buildField(
    String label,
    TextEditingController ctr,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String hint = "...",
  }) => CustomTextField(
    textColor: const Color(0xFFF15A5A),
    label: label,
    hint: hint,
    prefixIcon: Icon(icon, color: const Color(0xFFF15A5A)),
    textEditingController: ctr,
  );

  // بناء قائمة منسدلة لاختيار الفئة
  Widget _buildCategoryDropdown() {
    return Obx(
      () => SPDropdownButton(
        title: "الفئة", // Category
        hint: "اختر فئة المصروف", // Select expense category
        textColor: const Color(0xFFF15A5A),
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: Color(0xFFF15A5A),
        ),
        values: controller.categories
            .map((c) => "${c.name} (أولوية ${c.priority})")
            .toList(),
        onSelected: (index, value) {
          controller.selectedCategory.value = controller.categories[index];
          controller.categoryTextController.text = value;
        },
        textEditingController: controller.categoryTextController,
      ),
    );
  }

  // مفتاح تبديل لتحديد ما إذا كان المصروف ثابتاً شهرياً
  Widget _buildFixedToggle() => Obx(
    () => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF15A5A).withOpacity(0.5)),
      ),
      child: SwitchListTile(
        title: const Text(
          "مصروف شهري ثابت", // Fixed Monthly Expense
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        activeColor: const Color(0xFFF15A5A),
        value: isFixed.value,
        onChanged: (v) {
          isFixed.value = v;
          if (!v) controller.repeatController.clear();
        },
      ),
    ),
  );

  // حقل تحديد تكرار المصروف بالأيام
  Widget _buildRepetitionField() => Obx(
    () => isFixed.value
        ? _buildField(
            "يتكرر كل (أيام)", // Repeat Every (Days)
            controller.repeatController,
            Icons.calendar_month,
            keyboardType: TextInputType.number,
          )
        : const SizedBox.shrink(),
  );

  // أداة اختيار التاريخ
  Widget _buildDatePicker(BuildContext context) => Obx(
    () => DatePickerWidget(
      onTap: () => controller.fetchDate(context),
      selectedDate: controller.selectedDate.value,
      color: const Color(0xFFF15A5A),
    ),
  );

  // قائمة منسدلة لاختيار المحفظة المالية
  Widget _buildWalletDropdown() {
    return SPDropdownButton(
      title: "اختر المحفظة", // Select Wallet
      hint: "اختر المحفظة", // Choose wallet
      textColor: const Color(0xFFF15A5A),
      prefixIcon: const Icon(Icons.wallet, color: const Color(0xFFF15A5A)),
      values: controller.walletsListController.wallets
          .map(
            (w) =>
                "${w.currency.currencyName}      (${w.currency.code} ${w.balance})",
          )
          .toList(),
      onSelected: (index, value) {
        controller.selectedWallet.value =
            controller.walletsListController.wallets[index];
        controller.walletTextController.text = value;
      },
      textEditingController: controller.walletTextController,
      suffixIcon: IconButton(
        onPressed: () async {
          await Get.toNamed('/add-wallet');
          await controller.walletsListController.loadWallets();
        },
        icon: const Icon(Icons.add, color: const Color(0xFFF15A5A)),
      ),
    );
  }

  // قائمة منسدلة مع إمكانية البحث لتعيين "وسم" للمصروف
  Widget _buildTagDropdown() => Obx(
    () => SPDropdownButton(
      title: "اختر وسماً", // Select Tag
      isTextField: true, // تفعيل الكتابة لتمكين ميزة إنشاء تاج جديد تلقائياً
      hint: "ابحث أو اكتب وسماً", // Search/Type Tag
      textColor: const Color(0xFFF15A5A),
      prefixIcon: const Icon(Icons.tag, color: Color(0xFFF15A5A)),
      values: controller.tagController.myTags.map((t) => t.name).toList(),
      onSelected: (index, value) {
        controller.selectedTag.value = controller.tagController.myTags[index];
        controller.tagTextController.text = value;
      },
      textEditingController: controller.tagTextController,
    ),
  );

  // عرض الوسم المختار حالياً مع إمكانية حذفه
  Widget _buildTagPreview() => Obx(
    () => controller.selectedTag.value != null
        ? TagWidget(
            tagName: controller.selectedTag.value!.name,
            icon: Icons.check,
            color: const Color(0xFFF15A5A),
            onDelete: () {
              controller.selectedTag.value = null;
              controller.tagTextController.clear();
            },
          )
        : const SizedBox.shrink(),
  );

  // زر حفظ المصروف مع مؤشر تحميل عند المعالجة
  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: Obx(
      () => controller.isLoadingSave.value
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF15A5A)),
            )
          : CustomButton(
              text: "حفظ المصروف", // SAVE EXPENSE
              onPressed: () =>
                  controller.saveExpense(), // استدعاء الدالة المحدثة
              color: const Color(0xFFF15A5A),
            ),
    ),
  );
}
