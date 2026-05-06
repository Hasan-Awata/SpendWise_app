// تعليق: واجهة إضافة دخل جديد - تدعم الدخل الثابت والمزامنة مع المحفظة والوسوم
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/widgets/tag_widget.dart';
import 'package:spendwise/features/income/presentation/manager/add_income_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field_description.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddIncomeView extends StatefulWidget {
  const AddIncomeView({super.key});

  @override
  State<AddIncomeView> createState() => _AddIncomeViewState();
}

class _AddIncomeViewState extends State<AddIncomeView> {
  final controller = Get.find<AddIncomeController>();
  final RxBool isFixed = false.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                context,
              ).viewInsets.bottom, // يعطي مساحة مساوية لارتفاع الكيبورد
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // واجهة المستخدم: حقل إدخال المبلغ
                _buildField(
                  "المبلغ", // Amount
                  controller.amountController,
                  Icons.monetization_on_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 25),

                // واجهة المستخدم: حقل إدخال مصدر الدخل
                _buildField(
                  "المصدر", // Source
                  controller.sourceController,
                  Icons.source_outlined,
                ),
                const SizedBox(height: 25),

                _buildFixedToggle(),
                _buildRepetitionField(),
                const SizedBox(height: 25),

                // واجهة المستخدم: حقل الوصف
                CustomTextFieldDescription(
                  label: "الوصف", // Description
                  hint: "التفاصيل...", // Details...
                  textEditingController: controller.descriptionController,
                  textColor: SpColor.incomeGreen,
                ),
                const SizedBox(height: 25),

                _buildDatePicker(context),
                const SizedBox(height: 30),
                const Divider(color: Colors.white10, thickness: 1),
                const SizedBox(height: 30),

                _buildWalletDropdown(),
                const SizedBox(height: 25),

                _buildTagDropdown(),
                _buildTagPreview(),
                const SizedBox(height: 40),

                _buildSubmitButton(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء شريط التطبيق (AppBar)
  PreferredSizeWidget _buildAppBar() => AppBar(
    title: const Text(
      "إضافة دخل", // Add Income
      style: TextStyle(color: SpColor.incomeGreen, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: SpColor.incomeGreen,
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: () => Get.toNamed(Routes.LIST_INCOME),
        icon: const Icon(Icons.all_inbox_rounded),
      ),
    ],
  );

  // بناء حقل نصي مخصص مع أيقونة وتسمية
  Widget _buildField(
    String label,
    TextEditingController ctr,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) => CustomTextField(
    textColor: SpColor.incomeGreen,
    label: label,
    hint: "أدخل $label", // Enter $label
    prefixIcon: Icon(icon, color: SpColor.incomeGreen),
    textEditingController: ctr,
  );

  // مفتاح تبديل لتحديد ما إذا كان الدخل ثابتاً (دوري)
  Widget _buildFixedToggle() => Obx(
    () => Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: SpColor.incomeGreen.withOpacity(0.5)),
      ),
      child: SwitchListTile(
        title: const Text(
          "دخل ثابت", // Fixed Income
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        activeThumbColor: SpColor.incomeGreen,
        value: isFixed.value,
        onChanged: (v) => isFixed.value = v,
      ),
    ),
  );

  // حقل يظهر فقط عند تفعيل خيار الدخل الثابت لتحديد أيام التكرار
  Widget _buildRepetitionField() => Obx(
    () => isFixed.value
        ? Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildField(
              "يتكرر كل (أيام)", // Repeat Every (Days)
              controller.repeatController,
              Icons.calendar_month,
              keyboardType: TextInputType.number,
            ),
          )
        : const SizedBox.shrink(),
  );

  // أداة اختيار تاريخ استلام الدخل
  Widget _buildDatePicker(BuildContext context) => Obx(
    () => DatePickerWidget(
      onTap: () => controller.fetchDate(context),
      selectedDate: controller.selectedDate.value,
      color: SpColor.incomeGreen,
    ),
  );

  Widget _buildWalletDropdown() {
    return SPDropdownSearch(
      themeColor: SpColor.incomeGreen,
      label: "اضف محفظة",
      hint: "اختر المحفظة",

      // تحويل قائمة المحافظ إلى نصوص للعرض
      items: controller.walletsListController.wallets
          .map(
            (w) =>
                "${w.currency.currencyName} (${w.currency.code} ${w.balance})",
          )
          .toList(),
      // القيمة المختارة حالياً من الـ Controller
      selectedItem: controller.walletTextController.text.isNotEmpty
          ? controller.walletTextController.text
          : null,
      onChanged: (value) {
        if (value != null) {
          controller.walletTextController.text = value;
          // العثور على الـ index بناءً على النص المختار لتحديد المحفظة في الـ Controller
          int index = controller.walletsListController.wallets.indexWhere(
            (w) =>
                "${w.currency.currencyName} (${w.currency.code} ${w.balance})" ==
                value,
          );
          if (index != -1) {
            controller.selectedWallet.value =
                controller.walletsListController.wallets[index];
          }
        }
      },
      suffixIcon: IconButton(
        onPressed: () {
          Get.toNamed(Routes.ADD_WALLET);
        },
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTagDropdown() {
    return Obx(() {
      // التحقق مما إذا كان النص المكتوب يمثل وسماً جديداً غير موجود في القائمة
      bool isNewTag =
          controller.tagTextController.text.trim().isNotEmpty &&
          !controller.tagController.myTags.any(
            (t) =>
                t.name.toLowerCase() ==
                controller.tagTextController.text.trim().toLowerCase(),
          );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SPDropdownSearch(
            themeColor: SpColor.incomeGreen,
            label: "اختر الوسم",
            hint: "ابحث أو اكتب الوسم",
            // عرض قائمة أسماء الوسوم
            items: controller.tagController.myTags.map((t) => t.name).toList(),

            // ربط القيمة المختارة بالـ Controller
            selectedItem: controller.tagTextController.text.isNotEmpty
                ? controller.tagTextController.text
                : null,

            onChanged: (value) {
              if (value != null) {
                controller.tagTextController.text = value;

                // البحث عن الوسم المختار لتخزينه ككائن (Object) في selectedTag
                int index = controller.tagController.myTags.indexWhere(
                  (t) => t.name == value,
                );
                if (index != -1) {
                  controller.selectedTag.value =
                      controller.tagController.myTags[index];
                } else {
                  // في حال كان الوسم جديداً (كتبه المستخدم ولم يختاره من القائمة)
                  controller.selectedTag.value = null;
                }
              }
            },
            suffixIcon: IconButton(
              onPressed: () {
                Get.toNamed(Routes.ADD_TAG);
              },
              icon: Icon(Icons.add),
            ),
          ),

          // إظهار تنبيه المستخدم في حال إنشاء وسم جديد
          if (isNewTag)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 10.0),
              child: Text(
                "✨ سيتم إنشاء الوسم \"${controller.tagTextController.text}\".",
                style: const TextStyle(
                  color: SpColor.incomeGreen,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 10),
        ],
      );
    });
  }

  Widget _buildTagPreview() => Obx(
    () => controller.selectedTag.value != null
        ? Padding(
            padding: const EdgeInsets.only(top: 5),
            child: TagWidget(
              tagName: controller.selectedTag.value!.name,
              icon: Icons.tag,
              color: SpColor.incomeGreen,
              onDelete: () {
                controller.selectedTag.value = null;
                controller.tagTextController.clear();
              },
            ),
          )
        : const SizedBox.shrink(),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: Obx(
      () => controller.isLoadingSave.value
          ? const Center(
              child: CircularProgressIndicator(
                color: SpColor.incomeGreen,
                strokeWidth: 3,
              ),
            )
          : CustomButton(
              text: "حفظ الدخل", // SAVE INCOME
              onPressed: () => controller.saveIncome(),
              color: SpColor.incomeGreen,
            ),
    ),
  );
}
