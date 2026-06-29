import 'package:fintrack/controllers/auth_controller.dart';
import 'package:fintrack/controllers/home_controller.dart';
import 'package:fintrack/controllers/page_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopDrawerContent extends StatelessWidget {
  const TopDrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authC = Get.find<AuthController>();
    final controller = Get.find<HomeController>();
    final pagecontroller = Get.find<PageControllers>();
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName ?? user?.email?.split('@').first ?? "User";

    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 🔥 penting!
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: colors.primary,
                    child: Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        color: colors.inverseSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: colors.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ListTile(
                leading: Icon(Icons.home, color: colors.tertiary),
                title: Text("drawer_home".tr, style: TextStyle(color: colors.tertiary)),
                onTap: controller.closeDrawer,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),

              child: ListTile(
                leading: Icon(Icons.person, color: colors.tertiary),
                title: Text(
                  "drawer_profile".tr,
                  style: TextStyle(color: colors.tertiary),
                ),
                onTap: () {
                  pagecontroller.changePage(4); // index profile
                  controller.closeDrawer();
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),

              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  "drawer_logout".tr,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: authC.logout,
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
