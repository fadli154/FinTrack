import 'package:fintrack/controllers/thme_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAccountPage extends StatelessWidget {
  final String title;

  const MyAccountPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final themeController = Get.find<ThemeController>();
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "User";

    return Scaffold(
      appBar: AppBar(toolbarHeight: 3, backgroundColor: colors.secondary),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.secondary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 5,
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: colors.primary,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: colors.inverseSurface,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colors.inversePrimary,
                        ),
                      ),
                      Text(
                        "Hai, selamat datang di FinTrack!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 MENU CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.workspace_premium,
                      color: Color.fromARGB(255, 206, 192, 72),
                    ),
                    title: Text(
                      "Pusat Premium",
                      style: TextStyle(
                        color: Color.fromARGB(255, 206, 192, 72),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chevron_right,
                          color: Color.fromARGB(255, 206, 192, 72),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.thumb_up_alt_outlined,
                          title: "Rekomendasikan ke teman",
                        ),
                        _divider(context),
                        _buildMenuItem(
                          context,
                          icon: Icons.block,
                          title: "Blokir Iklan",
                        ),
                        _divider(context),
                        _buildMenuItem(
                          context,
                          icon: Icons.settings,
                          title: "Pengaturan",
                        ),
                        _divider(context),
                        Obx(
                          () => SwitchListTile(
                            title: Text(
                              "Dark Mode",
                              style: TextStyle(color: colors.inverseSurface),
                            ),
                            value: themeController.isDark.value,
                            onChanged: (_) {
                              themeController.toggleTheme();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool showDot = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colors.inverseSurface),
      title: Text(title, style: TextStyle(color: colors.inverseSurface)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          Icon(Icons.chevron_right, color: colors.inverseSurface),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _divider(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Divider(color: colors.secondary, height: 1);
  }
}
