import 'package:fintrack/controllers/admin_controller.dart';
import 'package:fintrack/core/models/app_user.dart';
import 'package:fintrack/pages/admin/admin_user_detail_page.dart';
import 'package:fintrack/widgets/ft_badge.dart';
import 'package:fintrack/widgets/ft_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ─── Search bar — using FtSearchBar shared widget ─────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: FtSearchBar(
            hintText: 'search_users'.tr,
            onChanged: (v) => ctrl.searchQuery.value = v,
          ),
        ),

        // ─── User list ────────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (ctrl.usersLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: colors.surface),
              );
            }
            final list = ctrl.filteredUsers;
            if (list.isEmpty) {
              return Center(
                child: Text(
                  'no_users_found'.tr,
                  style: TextStyle(color: colors.tertiary),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: list.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, i) => _UserTile(user: list[i]),
            );
          }),
        ),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Get.to(() => AdminUserDetailPage(user: user)),
      child: Container(
        // ─── Match home_page transaction card style ──────────────────────
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
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: user.isAdmin
                  ? Colors.amber.withValues(alpha: .2)
                  : colors.surface.withValues(alpha: .15),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: user.isAdmin
                      ? Colors.amber.shade700
                      : colors.surface,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            // ─ body title: tertiary (adapts light/dark) ──
                            color: colors.tertiary,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isAdmin) ...[
                        const SizedBox(width: 5),
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber.shade600,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12,
                      // caption: tertiary at lower opacity
                      color: colors.tertiary.withValues(alpha: .55),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status badge — using shared FtBadge
            FtBadge(
              label: user.isActive ? 'status_active'.tr : 'status_disabled'.tr,
              accentColor: user.isActive ? Colors.green : Colors.red,
              icon: user.isActive ? Icons.circle : Icons.remove_circle_outline,
            ),

            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.tertiary.withValues(alpha: .35),
            ),
          ],
        ),
      ),
    );
  }
}
