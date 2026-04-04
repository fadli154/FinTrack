import 'package:fintrack/partials/my_drawer.dart';
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
    MyHomePage(title: "home"),
    Center(child: Text("Add")),
    MyAccountPage(title: "account"),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Obx(() => _pages[pageController.pageIndex.value]),
      bottomNavigationBar: Obx(
        () => ConvexAppBar(
          backgroundColor: colors.secondary,
          initialActiveIndex: pageController.pageIndex.value,
          activeColor: colors.surface,
          color: colors.tertiary,
          cornerRadius: 5,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          elevation: 3,
          height: 65,
          style: TabStyle.fixedCircle,
          curveSize: 110,
          top: -35,
          items: [
            TabItem(icon: Icons.home, title: 'Home', fontFamily: 'Poppins'),
            TabItem(icon: Icons.add, title: 'Add'),
            TabItem(icon: Icons.people, title: 'Profile'),
          ],
          onTap: (int i) => pageController.changePage(i),
        ),
      ),

      drawer: MyDrawer(colors: colors, themeController: themeController),
    );
  }
}
