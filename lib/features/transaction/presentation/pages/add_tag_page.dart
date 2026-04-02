import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/transaction/data/models/tag_model.dart';
import 'package:spendwise/features/transaction/presentation/manager/tag_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button2.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';
import 'package:spendwise/features/widget_feature/helper_widget/dropdown_button.dart';

class AddtagPage extends StatefulWidget {
  const AddtagPage({super.key});

  @override
  State<AddtagPage> createState() => _AddtagPageState();
}

class _AddtagPageState extends State<AddtagPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late TagController _tagController;

  @override
  void initState() {
    super.initState();
    _tagController = Get.put(TagController());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _tagController.addtag(
      TagModel(
        id: 1,
        ownerId: 2,
        label: _nameController.text.trim(),
        categoryId: 1,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark,
        elevation: 0,
        title: const Text(
          "Add tag",
          style: TextStyle(
            color: SpColor.accentBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: SpColor.accentBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: "Tag Name",
                hint: "Tag Name",
                prefixIcon: const Icon(Icons.label_outline),
                textEditingController: _nameController,
              ),
              const SizedBox(height: 20),
              const Text(
                "Type",
                style: TextStyle(
                  color: SpColor.accentBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SPDropdownButton(
                controller: _tagController,
                title: "category",
                hint: "Select Category",
              ),
              const SizedBox(height: 42),
              CustomButton(
                onPressed: _submit,
                text: " save tag",
                color: SpColor.accentBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
