import 'package:fintrack/controllers/auth_controller.dart';
import 'package:fintrack/controllers/thme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key, required this.colors, required this.themeController});

  final ColorScheme colors;
  final ThemeController themeController;

  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: colors.secondary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: .7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome 👋",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      "Fadli",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          ListTile(
            leading: Icon(Icons.home, color: colors.tertiary),
            title: Text("Home", style: TextStyle(color: colors.tertiary)),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.person, color: colors.tertiary),
            title: Text("Profile", style: TextStyle(color: colors.tertiary)),
            onTap: () {},
          ),

          ListTile(
            leading: Icon(Icons.settings, color: colors.tertiary),
            title: Text("Settings", style: TextStyle(color: colors.tertiary)),
            onTap: () {},
          ),

          Obx(
            () => SwitchListTile(
              title: Text(
                "Dark Mode",
                style: TextStyle(color: colors.tertiary),
              ),
              secondary: Icon(Icons.dark_mode, color: colors.tertiary),
              value: themeController.isDark.value,
              onChanged: (value) {
                themeController.toggleTheme();
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.logout_sharp, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              authC.logout();
            },
          ),
        ],
      ),
    );
  }
}
