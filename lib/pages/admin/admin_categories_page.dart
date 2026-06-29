import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fintrack/controllers/admin_controller.dart';
import 'package:fintrack/widgets/ft_section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCategoriesPage extends StatelessWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();
    final colors = Theme.of(context).colorScheme;

    return Obx(() {
      final cats = ctrl.globalCategories;
      return Column(
        children: [
          // ─── Header + add button ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: FtSectionHeader(
              title: 'admin_categories'.tr,
              trailing: FilledButton.icon(
                onPressed: () => _showAddDialog(context, ctrl),
                icon: const Icon(Icons.add, size: 18),
                label: Text('add'.tr),
                style: FilledButton.styleFrom(
                  // Primary filled button: uses colors.surface (teal)
                  backgroundColor: colors.surface,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),

          // ─── Category list ────────────────────────────────────────────
          Expanded(
            child: cats.isEmpty
                ? Center(
                    child: Text(
                      'no_categories'.tr,
                      style: TextStyle(
                        color: colors.tertiary.withValues(alpha: .55),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: cats.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final cat = cats[i];
                      return Container(
                        // ─── Match home_page transaction card style ───────
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.secondary.withAlpha(50),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colors.tertiary.withValues(alpha: .1),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon container: circular, teal tint — matches
                            // category icons in home_page
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: colors.surface.withValues(alpha: .12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  cat['icon'] as String? ?? '📦',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cat['name'] as String? ?? '',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  // body text: colors.tertiary
                                  color: colors.tertiary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red.withValues(alpha: .7),
                                size: 20,
                              ),
                              onPressed: () => _confirmDelete(
                                context,
                                ctrl,
                                cat['id'] as String,
                                cat['name'] as String? ?? '',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  // ─── Add category bottom sheet — matches home_page _showAddModal style ───
  void _showAddDialog(BuildContext context, AdminController ctrl) {
    final colors = Theme.of(context).colorScheme;
    final nameCtrl = TextEditingController();
    final iconCtrl = TextEditingController(text: '📦');

    Get.bottomSheet(
      SafeArea(
        bottom: true,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            // ─── Match home_page bottom sheet style ──────────────────────
            color: colors.secondary,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.tertiary.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'add_category'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.tertiary,
                ),
              ),
              const SizedBox(height: 16),

              // Icon input
              TextField(
                controller: iconCtrl,
                style: TextStyle(color: colors.tertiary),
                decoration: InputDecoration(
                  labelText: 'category_icon'.tr,
                  labelStyle: TextStyle(
                    color: colors.tertiary.withValues(alpha: .6),
                  ),
                  filled: true,
                  fillColor: colors.secondary.withAlpha(80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colors.tertiary.withValues(alpha: .1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colors.tertiary.withValues(alpha: .1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: colors.surface, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Name input
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: colors.tertiary),
                decoration: InputDecoration(
                  labelText: 'category_name_hint'.tr,
                  labelStyle: TextStyle(
                    color: colors.tertiary.withValues(alpha: .6),
                  ),
                  filled: true,
                  fillColor: colors.secondary.withAlpha(80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colors.tertiary.withValues(alpha: .1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colors.tertiary.withValues(alpha: .1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: colors.surface, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Save button — uses colors.surface (teal) primary
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final navigator = Navigator.of(context);
                    await ctrl.addCategory(name, iconCtrl.text.trim());
                    navigator.pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.surface,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'save'.tr,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(
    BuildContext context,
    AdminController ctrl,
    String id,
    String name,
  ) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'delete_category'.tr,
      desc: 'delete_category_q'.trParams({'title': name}),
      btnCancelText: 'cancel'.tr,
      btnOkText: 'delete'.tr,
      btnOkColor: Colors.red,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await ctrl.deleteCategory(id);
      },
    ).show();
  }
}
