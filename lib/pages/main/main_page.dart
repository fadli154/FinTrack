import 'package:fintrack/partials/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';
import 'package:fintrack/controllers/page_controller.dart';
import 'package:fintrack/controllers/thme_controller.dart';
import 'package:fintrack/pages/main/account_page.dart';
import 'package:fintrack/pages/main/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MyMainPage extends StatelessWidget {
  final String title;

  MyMainPage({super.key, required this.title});

  final pageController = Get.find<PageControllers>();

  final themeController = Get.put(ThemeController());

  final List<Widget> _pages = [
    MyHomePage(title: "Riwayat"),
    Center(child: Text("Grafik")),
    Center(child: Text("Add")),
    Center(child: Text("Laporan")),
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

          height: 70,
          elevation: 8,
          shadowColor: colors.shadow.withValues(alpha: 0.25),

          cornerRadius: 20,
          curveSize: 120,
          top: -25,

          style: TabStyle.fixedCircle,

          items: const [
            TabItem(icon: Icons.event_note, title: 'Riwayat'),
            TabItem(icon: Icons.pie_chart, title: 'Grafik'),
            TabItem(icon: Icons.add, title: 'Add'),
            TabItem(icon: Icons.receipt_long_rounded, title: 'Laporan'),
            TabItem(icon: Icons.person_outline_sharp, title: 'Saya'),
          ],

          onTap: (int i) {
            if (i == 2) {
              _showAddModal(context);
            } else {
              pageController.changePage(i);
            }
          },
        ),
      ),

      drawer: MyDrawer(colors: colors, themeController: themeController),
    );
  }
}

void _showAddModal(BuildContext context) {
  final colors = Theme.of(context).colorScheme;

  Get.bottomSheet(
    FractionallySizedBox(
      heightFactor: 0.75,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tambahkan",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.tertiary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: colors.tertiary),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 2),
                    top: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),

                child: TabBar(
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: -53,
                    vertical: 0,
                  ),

                  indicator: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelColor: colors.inverseSurface,
                  dividerColor: Color.fromARGB(0, 217, 217, 217),
                  unselectedLabelColor: colors.tertiary,
                  tabs: [
                    Tab(text: "Pengeluaran"),
                    Tab(text: "Pemasukan"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildCategoryGrid("pengeluaran", context),
                    _buildCategoryGrid("pemasukan", context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

Widget _buildCategoryGrid(String type, BuildContext context) {
  final colors = Theme.of(context).colorScheme;

  final icons = [
    Icons.shopping_cart,
    Icons.fastfood,
    Icons.phone_android,
    Icons.movie,
  ];

  final titles = ["Belanja", "Makanan", "Telepon", "Hiburan"];

  return GridView.builder(
    itemCount: icons.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      mainAxisSpacing: 15,
      crossAxisSpacing: 10,
      childAspectRatio: 0.8,
    ),
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () {
          _showInputDialog(context, titles[index], type);
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.onSecondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icons[index], color: colors.inversePrimary, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              titles[index],
              style: TextStyle(fontSize: 11, color: colors.tertiary),
            ),
          ],
        ),
      );
    },
  );
}

void _showInputDialog(BuildContext context, String category, String type) {
  final colors = Theme.of(context).colorScheme;

  final amountC = TextEditingController();
  final noteC = TextEditingController();
  Rx<DateTime> selectedDate = DateTime.now().obs;

  Get.bottomSheet(
    FractionallySizedBox(
      heightFactor: 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$category",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: colors.tertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
