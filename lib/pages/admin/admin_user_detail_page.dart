import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fintrack/controllers/admin_controller.dart';
import 'package:fintrack/controllers/user_controller.dart';
import 'package:fintrack/core/models/app_user.dart';
import 'package:fintrack/core/services/permission_service.dart';
import 'package:fintrack/widgets/ft_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminUserDetailPage extends StatelessWidget {
  final AppUser user;
  const AdminUserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ctrl = Get.find<AdminController>();
    final me = Get.find<UserController>().currentUser.value;

    final canChangeRole = PermissionService.canChangeRole(me, user);
    final canDelete = PermissionService.canDeleteUser(me, user);

    return Scaffold(
      // ─── Scaffold bg: match user pages ────────────────────────────────
      backgroundColor: colors.secondary,

      appBar: AppBar(
        // ─── AppBar: match home_page style ────────────────────────────────
        backgroundColor: colors.primary,
        foregroundColor: colors.inverseSurface,
        elevation: 0,
        title: Text(
          'user_detail'.tr,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colors.inverseSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colors.inverseSurface),
          onPressed: () => Get.back(),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── Avatar + name header ──────────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: user.isAdmin
                      ? Colors.amber.withValues(alpha: .2)
                      : colors.surface.withValues(alpha: .15),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: user.isAdmin
                          ? Colors.amber.shade700
                          : colors.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.tertiary,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    color: colors.tertiary.withValues(alpha: .6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FtBadge(
                      label: user.isAdmin ? 'role_admin'.tr : 'role_user'.tr,
                      accentColor: user.isAdmin
                          ? Colors.amber.shade700
                          : colors.surface,
                      icon: user.isAdmin
                          ? Icons.star_rounded
                          : Icons.person_outline,
                    ),
                    const SizedBox(width: 8),
                    FtBadge(
                      label: user.isActive
                          ? 'status_active'.tr
                          : 'status_disabled'.tr,
                      accentColor: user.isActive ? Colors.green : Colors.red,
                      icon: user.isActive ? Icons.circle : Icons.block,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Info card — matches transaction item card style ───────────
          Container(
            decoration: BoxDecoration(
              color: colors.secondary.withAlpha(50),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors.tertiary.withValues(alpha: .1),
              ),
            ),
            child: Column(
              children: [
                _infoRow(context, Icons.person_outline_rounded,
                    'name'.tr, user.name),
                _divider(colors),
                _infoRow(context, Icons.email_outlined, 'email'.tr, user.email),
                _divider(colors),
                _infoRow(
                  context,
                  Icons.calendar_today_outlined,
                  'created_at_label'.tr,
                  user.createdAt != null
                      ? DateFormat('dd MMM yyyy').format(user.createdAt!)
                      : '-',
                ),
                _divider(colors),
                _infoRow(
                  context,
                  Icons.access_time_rounded,
                  'last_login_label'.tr,
                  user.lastLogin != null
                      ? DateFormat('dd MMM yyyy HH:mm').format(user.lastLogin!)
                      : '-',
                ),
                _divider(colors),
                _infoRow(context, Icons.language_outlined,
                    'language'.tr, user.language.toUpperCase()),
                _divider(colors),
                _infoRow(context, Icons.attach_money_rounded,
                    'currency'.tr, user.currency),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Action buttons ────────────────────────────────────────────
          if (canChangeRole) ...[
            _actionButton(
              context,
              icon: user.isAdmin
                  ? Icons.person_remove_outlined
                  : Icons.star_outline_rounded,
              label: user.isAdmin
                  ? 'demote_to_user'.tr
                  : 'promote_to_admin'.tr,
              accentColor: Colors.amber.shade700,
              onTap: () async {
                final confirm = await _confirm(
                  context,
                  title: user.isAdmin
                      ? 'demote_to_user'.tr
                      : 'promote_to_admin'.tr,
                  desc: user.isAdmin
                      ? 'demote_confirm'.tr
                      : 'promote_confirm'.tr,
                );
                if (!confirm) return;
                if (user.isAdmin) {
                  await ctrl.demoteToUser(user.uid);
                } else {
                  await ctrl.promoteToAdmin(user.uid);
                }
                Get.back();
                Get.snackbar(
                  'success'.tr,
                  user.isAdmin ? 'user_demoted'.tr : 'user_promoted'.tr,
                  backgroundColor: colors.surface,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(15),
                  borderRadius: 12,
                );
              },
            ),
            const SizedBox(height: 10),
          ],

          _actionButton(
            context,
            icon: user.isActive
                ? Icons.block_outlined
                : Icons.check_circle_outline_rounded,
            label: user.isActive
                ? 'disable_account'.tr
                : 'enable_account'.tr,
            accentColor: user.isActive ? Colors.orange : Colors.green,
            onTap: () async {
              final confirm = await _confirm(
                context,
                title: user.isActive
                    ? 'disable_account'.tr
                    : 'enable_account'.tr,
                desc: user.isActive
                    ? 'disable_confirm'.tr
                    : 'enable_confirm'.tr,
              );
              if (!confirm) return;
              if (user.isActive) {
                await ctrl.disableUser(user.uid);
              } else {
                await ctrl.enableUser(user.uid);
              }
              Get.back();
              Get.snackbar(
                'success'.tr,
                user.isActive ? 'user_disabled'.tr : 'user_enabled'.tr,
                backgroundColor: colors.surface,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(15),
                borderRadius: 12,
              );
            },
          ),

          if (canDelete) ...[
            const SizedBox(height: 10),
            _actionButton(
              context,
              icon: Icons.delete_forever_outlined,
              label: 'delete_user'.tr,
              accentColor: Colors.red,
              onTap: () => _deleteUser(context, ctrl),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── Delete with AwesomeDialog ───────────────────────────────────────────
  void _deleteUser(BuildContext context, AdminController ctrl) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'delete_user'.tr,
      desc: 'delete_user_confirm'.tr,
      btnCancelText: 'cancel'.tr,
      btnOkText: 'delete'.tr,
      btnOkColor: Colors.red,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final colors = Theme.of(context).colorScheme;
        await ctrl.deleteUser(user.uid);
        Get.back();
        Get.snackbar(
          'success'.tr,
          'user_deleted'.tr,
          backgroundColor: colors.surface,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(15),
          borderRadius: 12,
        );
      },
    ).show();
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String desc,
  }) async {
    bool result = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnCancelText: 'cancel'.tr,
      btnOkText: 'confirm'.tr,
      btnCancelOnPress: () {},
      btnOkOnPress: () => result = true,
    ).show();
    return result;
  }

  // ─── Info row helper ─────────────────────────────────────────────────────
  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          // Icon: uses surface (teal) matching home_page category icons
          Icon(icon, size: 18, color: colors.surface),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: colors.tertiary.withValues(alpha: .6),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: colors.tertiary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme colors) => Divider(
        height: 1,
        indent: 46,
        endIndent: 16,
        color: colors.tertiary.withValues(alpha: .08),
      );

  // ─── Action button — matches OutlinedButton style from user pages ────────
  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: accentColor),
        label: Text(label, style: TextStyle(color: accentColor)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accentColor.withValues(alpha: .4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
