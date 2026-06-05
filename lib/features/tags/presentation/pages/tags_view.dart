import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_action_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';

class TagsView extends GetView<TagViewController> {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tagActionController = Get.find<TagActionController>();

    return Scaffold(
      backgroundColor: const Color(0xFF020817),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        centerTitle: true,

        title: const Text(
          "الوسوم",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SpColor.tagColor,

        onPressed: () => Get.toNamed('/add-tag'),

        icon: const Icon(Icons.add_rounded, color: Colors.white),

        label: const Text(
          "إضافة محفظة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: RefreshIndicator(
        color: SpColor.tagColor,
        backgroundColor: const Color(0xFF1E293B),

        onRefresh: () async => await controller.refreshmyTags(),

        child: Obx(() {
          // =========================
          // LOADING
          // =========================

          if (controller.isLoading.value && controller.myTags.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: SpColor.tagColor),
            );
          }

          // =========================
          // EMPTY
          // =========================

          if (controller.myTags.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              children: const [
                SizedBox(height: 220),

                Icon(Icons.list_alt_outlined, color: Colors.white24, size: 80),

                SizedBox(height: 20),

                Center(
                  child: Text(
                    "لا توجد وسوم حالياً",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              ],
            );
          }

          // =========================
          // LIST
          // =========================

          return ListView.builder(
            controller: controller.scrollController,

            physics: const AlwaysScrollableScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),

            padding: const EdgeInsets.all(16),

            itemCount:
                controller.myTags.length +
                (controller.hasMoreData.value ? 1 : 0),

            itemBuilder: (context, index) {
              if (index < controller.myTags.length) {
                return _buildtagCard(tagActionController, index);
              }

              return const Padding(
                padding: EdgeInsets.all(20),

                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          );
        }),
      ),
    );
  }

  // =========================
  // tag CARD
  // =========================

  Widget _buildtagCard(TagActionController tagActionController, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),

        border: Border.all(color: Colors.white12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          _buildIcon(),

          const SizedBox(width: 16),

          Expanded(child: _buildtagDetails(index)),

          _buildActions(index, tagActionController),
        ],
      ),
    );
  }

  // =========================
  // ICON
  // =========================

  Widget _buildIcon() {
    return Container(
      width: 58,
      height: 58,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        gradient: LinearGradient(
          colors: [SpColor.tagColor, SpColor.tagColor.withOpacity(0.7)],
        ),
      ),

      child: const Icon(Icons.tag, color: Colors.white, size: 28),
    );
  }

  // =========================
  // DETAILS
  // =========================

  Widget _buildtagDetails(int index) {
    final tag = controller.myTags[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          tag.name,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          tag.name,

          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),

        const SizedBox(height: 10),

        _syncStatus(index),
      ],
    );
  }

  // =========================
  // SYNC STATUS
  // =========================

  // spendwise/features/tag/presentation/widgets/sync_status.dart

  Widget _syncStatus(int index) {
    return Obx(() {
      final RxBool synced = controller.myTags[index].isSynced;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: synced.value
              ? Colors.green.withOpacity(0.12)
              : Colors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          synced.value ? "متزامن" : "غير متزامن",
          style: TextStyle(
            color: synced.value ? Colors.greenAccent : Colors.orangeAccent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }

  // =========================
  // ACTIONS
  // =========================

  Widget _buildActions(int index, TagActionController tagActionController) {
    final tag = controller.myTags[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        Text(
          tag.name,

          style: const TextStyle(
            color: SpColor.tagColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            _iconBtn(
              Icons.edit,
              Colors.blueAccent,
              () => _showUpdateDialog(tag, tagActionController),
            ),

            const SizedBox(width: 6),

            _iconBtn(
              Icons.delete,
              Colors.redAccent,
              () => _showDeleteDialog(tag, tagActionController),
            ),
          ],
        ),
      ],
    );
  }

  // =========================
  // ICON BUTTON
  // =========================

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),

        borderRadius: BorderRadius.circular(12),
      ),

      child: IconButton(
        icon: Icon(icon, color: color, size: 20),

        onPressed: onTap,
      ),
    );
  }

  // =========================
  // UPDATE DIALOG
  // =========================

  void _showUpdateDialog(TagEntity tag, TagActionController ctrl) {
    final textController = TextEditingController(text: tag.name);
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF111827),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Text(
                "تعديل الوسم",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: textController,

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  labelText: "الاسم الجديد",

                  labelStyle: const TextStyle(color: Colors.white70),

                  filled: true,

                  fillColor: Colors.white.withOpacity(0.04),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpColor.tagColor,
                  ),

                  onPressed: () async {
                    await ctrl.updateTag(tag, textController.text);
                  },

                  child: const Text(
                    "حفظ التعديلات",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // DELETE DIALOG
  // =========================

  void _showDeleteDialog(TagEntity tag, TagActionController ctrl) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF111827),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
                size: 60,
              ),

              const SizedBox(height: 15),

              const Text(
                "حذف المحفظة",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "هل تريد حذف هذه المحفظة؟",

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),

                      child: const Text("إلغاء"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),

                      onPressed: () {
                        ctrl.deleteTag(tag);
                        Get.back();
                      },

                      child: const Text("حذف"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
