import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_controller.dart'
    show TagController;
import 'package:spendwise/features/tags/presentation/pages/add_tag_page.dart'
    show AddtagPage;
import 'package:spendwise/features/tags/presentation/widgets/show_tag_widget.dart';

class TagsView extends StatelessWidget {
  TagsView({super.key});

  // // Logic: Using Get.find if the controller is already initialized, or Get.put if not.
  final TagController _tagController = Get.find<TagController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark2,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Tags",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: SpColor.accentBlue,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      // // Logic: Using Obx to make the UI reactive so it updates when tags change
      body: Obx(() {
        // // UI: Show a placeholder if the list is empty
        if (_tagController.myTags.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: _tagController.myTags.length,
          // // Layout: Better spacing between list items
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tag = _tagController.myTags[index];

            // // Logic: Dynamic data mapping from the model to the widget
            return ShowTagWidget(
              color: SpColor
                  .accentBlue, // You can make this dynamic if TagModel has a color field
              icon: Icons
                  .tag_rounded, // Dynamic icon based on category if available
              tagName: tag.name, // Displaying the actual tag name
            );
          },
        );
      }),
      // // Design: Floating Action Button for quick access to add a new tag
      floatingActionButton: FloatingActionButton(
        backgroundColor: SpColor.accentBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Get.to(() => const AddtagPage());
        },
      ),
    );
  }

  // // UI Component: Clean helper widget for empty states
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.label_off_outlined, size: 80, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            "No tags found",
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            "Create your first tag to organize expenses",
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
