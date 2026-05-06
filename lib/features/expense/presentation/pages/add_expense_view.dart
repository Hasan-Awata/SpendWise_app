// // AddExpenseView - Integrated with dynamic product chips
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

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildField(
                "عنوان المصروف",
                controller.titleTextController,
                Icons.title,
                hint: "مثال: بقالة، مطعم...",
              ),
              const SizedBox(height: 20),
              _buildField(
                "المبلغ (ريال)",
                controller.amountController,
                Icons.monetization_on_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              _buildCategoryDropdown(),
              const SizedBox(height: 25),
              // // New Product Section
              _buildProductSection(),
              const SizedBox(height: 25),
              _buildFixedToggle(),
              const SizedBox(height: 15),
              _buildRepetitionField(),
              const SizedBox(height: 25),
              CustomTextFieldDescription(
                label: "الوصف",
                hint: "تفاصيل إضافية...",
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
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    title: const Text(
      "مصروف جديد",
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

  Widget _buildCategoryDropdown() {
    return Obx(
      () => SPDropdownSearch(
        themeColor: SpColor.expenseRed,
        label: "الفئة",
        hint: "اختر الفئة",
        items: controller.categories.map((c) => c.name).toList(),
        selectedItem: controller.selectedCategory.value?.name,
        onChanged: (value) {
          if (value != null) {
            final cat = controller.categories.firstWhereOrNull(
              (c) => c.name == value,
            );
            controller.selectedCategory.value = cat;
          }
        },
      ),
    );
  }

  // // Section for adding products as Chips
  Widget _buildProductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: "المنتجات",
                hint: "اكتب اسم المنتج ثم أضفه",
                prefixIcon: const Icon(
                  Icons.shopping_basket,
                  color: Color(0xFFF15A5A),
                ),
                textEditingController: controller.productsController,
                textColor: const Color(0xFFF15A5A),
                onTap: () => controller.addProductToList(),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => controller.addProductToList(),
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFFF15A5A),
                size: 38,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: controller.tempProducts.map((product) {
              return Chip(
                label: Text(
                  product,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: SpColor.expenseRed,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: SpColor.surfaceNavy,
                deleteIcon: const Icon(
                  Icons.close,
                  size: 14,
                  color: SpColor.expenseRed,
                ),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFF15A5A)),
                  borderRadius: BorderRadius.circular(10),
                ),
                onDeleted: () => controller.removeProduct(product),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedToggle() => Obx(
    () => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF15A5A).withOpacity(0.5)),
      ),
      child: SwitchListTile(
        title: const Text(
          "مصروف شهري ثابت",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        activeThumbColor: const Color(0xFFF15A5A),
        value: isFixed.value,
        onChanged: (v) => isFixed.value = v,
      ),
    ),
  );

  Widget _buildRepetitionField() => Obx(
    () => isFixed.value
        ? _buildField(
            "يتكرر كل (أيام)",
            controller.repeatController,
            Icons.calendar_month,
            keyboardType: TextInputType.number,
          )
        : const SizedBox.shrink(),
  );

  Widget _buildDatePicker(BuildContext context) => Obx(
    () => DatePickerWidget(
      onTap: () => controller.fetchDate(context),
      selectedDate: controller.selectedDate.value,
      color: const Color(0xFFF15A5A),
    ),
  );

  Widget _buildWalletDropdown() {
    return SPDropdownSearch(
      themeColor: SpColor.expenseRed,
      label: "اضف محفظة",
      hint: "اختر المحفظة",

      items: controller.walletsListController.wallets
          .map(
            (w) =>
                "${w.currency.currencyName} (${w.currency.code} ${w.balance})",
          )
          .toList(),

      selectedItem: controller.walletTextController.text.isNotEmpty
          ? controller.walletTextController.text
          : null,
      onChanged: (value) {
        if (value != null) {
          controller.walletTextController.text = value;

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
            themeColor: SpColor.expenseRed,
            label: "اختر الوسم",
            hint: "ابحث أو اكتب الوسم",
            // عرض قائمة أسماء الوسوم
            items: controller.tagController.myTags.map((t) => t.name).toList(),
            selectedItem: controller.tagTextController.text.isNotEmpty
                ? controller.tagTextController.text
                : null,

            onChanged: (value) {
              if (value != null) {
                controller.tagTextController.text = value;

                int index = controller.tagController.myTags.indexWhere(
                  (t) => t.name == value,
                );
                if (index != -1) {
                  controller.selectedTag.value =
                      controller.tagController.myTags[index];
                } else {
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
        ? TagWidget(
            tagName: controller.selectedTag.value!.name,
            icon: Icons.check,
            color: const Color(0xFFF15A5A),
            onDelete: () => controller.selectedTag.value = null,
          )
        : const SizedBox.shrink(),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: Obx(
      () => controller.isLoadingSave.value
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF15A5A)),
            )
          : CustomButton(
              text: "حفظ المصروف",
              onPressed: () => controller.saveExpense(),
              color: const Color(0xFFF15A5A),
            ),
    ),
  );
}
