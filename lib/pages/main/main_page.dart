import 'package:fintrack/pages/main/chart_page.dart';
import 'package:fintrack/pages/main/laporan_page.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';
import 'package:fintrack/controllers/page_controller.dart';
import 'package:fintrack/controllers/thme_controller.dart';
import 'package:fintrack/pages/main/account_page.dart';
import 'package:fintrack/pages/main/home_page.dart';

class MyMainPage extends StatelessWidget {
  final String title;

  MyMainPage({super.key, required this.title});

  final pageController = Get.find<PageControllers>();

  final themeController = Get.put(ThemeController());

  final List<Widget> _pages = [
    MyHomePage(title: "FinTrack"),
    ChartPage(),
    Center(child: Text("baok")),
    LaporanPage(),
    MyAccountPage(title: "account"),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Obx(() => _pages[pageController.pageIndex.value]),
      bottomNavigationBar: Obx(
        () => ConvexAppBar(
          controller: pageController.tabController,
          backgroundColor: colors.secondary,
          initialActiveIndex: pageController.pageIndex.value,

          activeColor: colors.surface,
          color: colors.tertiary,

          height: 70,
          elevation: 8,
          shadowColor: colors.shadow.withValues(alpha: 0.25),

          cornerRadius: 20,
          curveSize: 0,
          top: -45,

          style: TabStyle.fixedCircle,

          items: [
            TabItem(icon: Icons.event_note, title: 'nav_history'.tr),
            TabItem(icon: Icons.pie_chart, title: 'nav_charts'.tr),
            TabItem(icon: Icons.camera_alt_rounded, title: 'nav_camera'.tr),
            TabItem(icon: Icons.receipt_long_rounded, title: 'nav_reports'.tr),
            TabItem(icon: Icons.person_outline_sharp, title: 'nav_me'.tr),
          ],

          onTap: (int i) {
            if (i == 2) {
              Get.toNamed('/yolo');
            } else {
              pageController.changePage(i);
            }
          },
        ),
      ),
    );
  }
}
