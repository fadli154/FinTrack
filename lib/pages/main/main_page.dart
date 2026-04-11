import 'package:fintrack/controllers/add_controller.dart';
import 'package:fintrack/controllers/home_controller.dart';
import 'package:fintrack/pages/main/chart_page.dart';
import 'package:fintrack/pages/main/laporan_page.dart';
import 'package:fintrack/partials/my_drawer.dart';
import 'package:fintrack/services/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';
import 'package:fintrack/controllers/page_controller.dart';
import 'package:fintrack/controllers/thme_controller.dart';
import 'package:fintrack/pages/main/account_page.dart';
import 'package:fintrack/pages/main/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MyMainPage extends StatelessWidget {
  final String title;

  MyMainPage({super.key, required this.title});

  final pageController = Get.find<PageControllers>();

  final themeController = Get.put(ThemeController());

  final List<Widget> _pages = [
    MyHomePage(title: "Riwayat"),
    ChartPage(),
    Center(child: Text("baok")),
    LaporanPage(),
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
  final controller = Get.put(AddController());
  final homeController = Get.find<HomeController>();

  return StreamBuilder(
    stream: controller.getCategories(type),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data?.docs ?? [];

      return GridView.builder(
        itemCount: docs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 15,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final doc = docs[index];
          final data = doc.data();

          final categoryId = doc.id;
          final title = data['name'];
          final icon = data['icon'];
          final color = data['color'];

          return GestureDetector(
            onTap: () {
              _showInputDialog(context, categoryId, title, type);
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: homeController.getColorFromHex(color),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    homeController.getIconFromString(icon),
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: colors.tertiary),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showInputDialog(
  BuildContext context,
  String categoryId,
  String categoryName,
  String type,
) {
  final controller = Get.find<AddController>();
  final colors = Theme.of(context).colorScheme;
  RxBool isValid = false.obs;

  final amountC = TextEditingController();
  final noteC = TextEditingController();
  Rx<DateTime> selectedDate = DateTime.now().obs;

  void validate() {
    final raw = amountC.text.replaceAll(RegExp(r'[^0-9]'), '');
    final number = int.tryParse(raw) ?? 0;
    isValid.value = number > 0;
  }

  amountC.addListener(validate);
  noteC.addListener(validate);

  Get.bottomSheet(
    FractionallySizedBox(
      heightFactor: 0.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // 🔹 HANDLE BAR
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // 🔹 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.tertiary,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: colors.tertiary),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 INPUT AMOUNT
            TextField(
              controller: amountC,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Rp 0",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color.fromARGB(217, 245, 245, 245),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 INPUT NOTE
            TextField(
              controller: noteC,
              style: const TextStyle(color: Colors.black),

              decoration: InputDecoration(
                hintText: "Catatan",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color.fromARGB(213, 245, 245, 245),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 DATE PICKER
            Obx(
              () => ListTile(
                title: Text(
                  "Tanggal: ${selectedDate.value.toString().split(' ')[0]}",
                  style: TextStyle(color: colors.tertiary),
                ),
                trailing: Icon(Icons.calendar_today, color: colors.tertiary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: colors,
                          primaryColor: colors.primary,
                          cardColor: colors.secondary,
                          canvasColor: colors.secondary,
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    selectedDate.value = picked;
                  }
                },
              ),
            ),

            const Spacer(),

            // 🔹 BUTTON SAVE
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isValid.value
                      ? () async {
                          final raw = amountC.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          final amount = int.tryParse(raw) ?? 0;

                          await controller.addTransaction(
                            categoryId: categoryId,
                            amount: amount,
                            note: noteC.text,
                            date: selectedDate.value,
                          );
                          Get.back();
                          Get.back();
                          AwesomeDialog(
                            context: Get.overlayContext!,
                            dialogType: DialogType.success,
                            animType: AnimType.scale,
                            dialogBackgroundColor: colors.secondary,
                            titleTextStyle: TextStyle(color: colors.tertiary),
                            descTextStyle: TextStyle(color: colors.tertiary),
                            dismissOnTouchOutside: false,

                            body: Column(
                              children: [
                                Text(
                                  "Berhasil!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.tertiary,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Transaksi berhasil ditambahkan",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.tertiary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                            btnOkColor: colors.primary,

                            btnOkOnPress: () async {
                              try {
                                Get.back();

                                showSnack(
                                  title: "Sukses",
                                  message: "Transaksi berhasil ditambahkan",
                                );
                              } catch (e) {
                                showSnack(
                                  title: "Error",
                                  message: e.toString(),
                                );
                              }
                            },
                          ).show();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.inverseSurface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Simpan"),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

void showSnack({
  required String title,
  required String message,
  bool isError = false,
}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.fromLTRB(15, 15, 15, 110),
    borderRadius: 12,
    backgroundColor: isError ? Colors.red.shade400 : Colors.teal,
    colorText: Colors.white,
    icon: Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
    duration: const Duration(seconds: 3),
    mainButton: TextButton(
      onPressed: () => Get.back(),
      child: const Text("Tutup", style: TextStyle(color: Colors.white)),
    ),
  );
}
