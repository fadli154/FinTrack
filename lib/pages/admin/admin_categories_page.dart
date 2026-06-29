import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fintrack/controllers/admin_controller.dart';
import 'package:fintrack/widgets/ft_section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Preset color swatches for category color picker
const _kColorSwatches = [
  Color(0xFF26A69A), // teal
  Color(0xFF42A5F5), // blue
  Color(0xFF66BB6A), // green
  Color(0xFFFF7043), // orange
  Color(0xFFAB47BC), // purple
  Color(0xFFFFCA28), // amber
  Color(0xFFEF5350), // red
  Color(0xFF78909C), // slate
];

String _colorToHex(Color c) =>
    '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

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
          // ─── Header + Add button ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: FtSectionHeader(
              title: 'admin_categories'.tr,
              trailing: FilledButton.icon(
                onPressed: () => _showAddDialog(context, ctrl),
                icon: const Icon(Icons.add, size: 18),
                label: Text('add'.tr),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.surface,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          color: colors.tertiary.withValues(alpha: .55)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: cats.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final cat = cats[i];
                      final colorHex =
                          cat['color'] as String? ?? '#9E9E9E';
                      final catColor = _hexToColor(colorHex);
                      final isIncome =
                          (cat['type'] as String?) == 'pemasukan';

                      return Container(
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
                            // Icon with category color
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: .15),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat['name'] as String? ?? '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: colors.tertiary,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isIncome
                                          ? Colors.green.withValues(alpha: .12)
                                          : Colors.red.withValues(alpha: .12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isIncome
                                          ? 'type_income'.tr
                                          : 'type_expense'.tr,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isIncome
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
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

  // ─── Add category bottom sheet ────────────────────────────────────────────

  void _showAddDialog(BuildContext context, AdminController ctrl) {
    final colors = Theme.of(context).colorScheme;
    final nameCtrl = TextEditingController();
    final iconCtrl = TextEditingController(text: '📦');
    final selectedType = 'pengeluaran'.obs;
    final selectedColor = _kColorSwatches.first.obs;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) => SafeArea(
          bottom: true,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SingleChildScrollView(
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

                  // Name input
                  _inputField(
                    context,
                    controller: nameCtrl,
                    label: 'category_name_hint'.tr,
                  ),
                  const SizedBox(height: 12),

                  // Icon input
                  _inputField(
                    context,
                    controller: iconCtrl,
                    label: 'category_icon'.tr,
                  ),
                  const SizedBox(height: 12),

                  // Type selector
                  Text(
                    'category_type'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.tertiary.withValues(alpha: .7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _typeChip(
                            context,
                            label: 'type_income'.tr,
                            value: 'pemasukan',
                            selected:
                                selectedType.value == 'pemasukan',
                            color: Colors.green,
                            onTap: () =>
                                selectedType.value = 'pemasukan',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _typeChip(
                            context,
                            label: 'type_expense'.tr,
                            value: 'pengeluaran',
                            selected:
                                selectedType.value == 'pengeluaran',
                            color: Colors.red,
                            onTap: () =>
                                selectedType.value = 'pengeluaran',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Color picker
                  Text(
                    'category_color'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.tertiary.withValues(alpha: .7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _kColorSwatches.map((c) {
                        final isSelected = selectedColor.value == c;
                        return GestureDetector(
                          onTap: () => selectedColor.value = c,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? colors.tertiary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: c.withValues(alpha: .5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        final navigator = Navigator.of(context);
                        await ctrl.addCategory(
                          name: name,
                          type: selectedType.value,
                          icon: iconCtrl.text.trim(),
                          color: _colorToHex(selectedColor.value),
                        );
                        navigator.pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.surface,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'save'.tr,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _inputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      style: TextStyle(color: colors.tertiary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.tertiary.withValues(alpha: .6)),
        filled: true,
        fillColor: colors.secondary.withAlpha(80),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: colors.tertiary.withValues(alpha: .1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: colors.tertiary.withValues(alpha: .1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.surface, width: 1.5),
        ),
      ),
    );
  }

  Widget _typeChip(
    BuildContext context, {
    required String label,
    required String value,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.grey.withValues(alpha: .3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? color : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(
        int.parse(hex.replaceFirst('#', 'FF'), radix: 16),
      );
    } catch (_) {
      return const Color(0xFF9E9E9E);
    }
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
