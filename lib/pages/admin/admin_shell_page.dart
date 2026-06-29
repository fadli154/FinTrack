import 'package:fintrack/controllers/admin_controller.dart';
import 'package:fintrack/controllers/auth_controller.dart';
import 'package:fintrack/controllers/user_controller.dart';
import 'package:fintrack/pages/admin/admin_categories_page.dart';
import 'package:fintrack/pages/admin/admin_dashboard_page.dart';
import 'package:fintrack/pages/admin/admin_users_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminController());
    final colors = Theme.of(context).colorScheme;
    final selectedIndex = 0.obs;

    final pages = [
      const AdminDashboardPage(),
      const AdminUsersPage(),
      const AdminCategoriesPage(),
    ];

    return Obx(() {
      final user = Get.find<UserController>().currentUser.value;

      final labels = [
        'admin_dashboard'.tr,
        'admin_users'.tr,
        'admin_categories'.tr,
      ];

      final icons = [
        Icons.dashboard_outlined,
        Icons.people_outline,
        Icons.category_outlined,
      ];

      final selectedIcons = [
        Icons.dashboard_rounded,
        Icons.people_rounded,
        Icons.category_rounded,
      ];

      return Scaffold(
        // ─── Match user Scaffold background ─────────────────────────────
        backgroundColor: colors.secondary,

        appBar: AppBar(
          // ─── Match home_page AppBar style ───────────────────────────────
          backgroundColor: colors.primary,
          foregroundColor: colors.inverseSurface,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FinTrack Admin',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colors.inverseSurface,
                ),
              ),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.inverseSurface.withValues(alpha: .75),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: colors.inverseSurface),
              tooltip: 'Refresh',
              onPressed: () => Get.find<AdminController>().loadStats(),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors.inverseSurface),
              onSelected: (v) {
                if (v == 'logout') {
                  Get.find<AuthController>().logout();
                } else if (v == 'user_app') {
                  Get.offAllNamed('/main');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'user_app',
                  child: Row(
                    children: [
                      Icon(Icons.switch_account,
                          size: 18, color: colors.surface),
                      const SizedBox(width: 8),
                      Text('switch_to_user_app'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'drawer_logout'.tr,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        body: pages[selectedIndex.value],

        // ─── Match user bottom nav color tokens ─────────────────────────
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex.value,
          onDestinationSelected: (i) => selectedIndex.value = i,
          backgroundColor: colors.secondary,
          // Active indicator: teal tint matching ConvexAppBar active color
          indicatorColor: colors.surface.withValues(alpha: .18),
          surfaceTintColor: Colors.transparent,
          shadowColor: colors.shadow.withValues(alpha: 0.25),
          elevation: 8,
          destinations: List.generate(
            3,
            (i) => NavigationDestination(
              // Inactive: colors.tertiary.withValues - matching ConvexAppBar `color`
              icon: Icon(
                icons[i],
                color: colors.tertiary.withValues(alpha: .45),
              ),
              // Selected: colors.surface (teal) - matching ConvexAppBar activeColor
              selectedIcon: Icon(selectedIcons[i], color: colors.surface),
              label: labels[i],
            ),
          ),
        ),
      );
    });
  }
}
