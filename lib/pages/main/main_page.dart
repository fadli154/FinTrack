import 'package:fintrack/controllers/add_controller.dart';
import 'package:fintrack/controllers/home_controller.dart';
import 'package:fintrack/pages/main/chart_page.dart';
import 'package:fintrack/pages/main/laporan_page.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

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
    );
  }
}

void _showAddModal(BuildContext context) {
  final colors = Theme.of(context).colorScheme;

  Get.bottomSheet(
    SafeArea(
      bottom: true,
      child: FractionallySizedBox(
        heightFactor: 0.8,
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
        itemCount: docs.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 15,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          // 🔥 kalau index terakhir → tombol tambah
          if (index == docs.length) {
            return GestureDetector(
              onTap: () {
                _showAddCategoryDialog(context, type);
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withAlpha(150),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tambah",
                    style: TextStyle(fontSize: 11, color: colors.tertiary),
                  ),
                ],
              ),
            );
          }

          // 🔥 item normal (kategori)
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
            child: Stack(
              children: [
                Column(
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
              ],
            ),
          );
        },
      );
    },
  );
}

void _confirmDeleteCategory(
  BuildContext context,
  String categoryId,
  String title,
) {
  final controller = Get.find<AddController>();
  final colors = Theme.of(context).colorScheme;

  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.scale,
    dialogBackgroundColor: colors.secondary,

    title: "Hapus Kategori",
    desc: "Yakin mau hapus '$title'?",

    titleTextStyle: TextStyle(color: colors.tertiary),
    descTextStyle: TextStyle(color: colors.tertiary),

    btnCancelText: "Batal",
    btnCancelColor: colors.primary,

    btnOkText: "Hapus",
    btnOkColor: Colors.red,

    btnOkOnPress: () async {
      try {
        await controller.deleteCategory(categoryId);

        showSnack(title: "Sukses", message: "Kategori berhasil dihapus");
      } catch (e) {
        showSnack(title: "Error", message: e.toString(), isError: true);
      }
    },
  ).show();
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
    SafeArea(
      bottom: true,
      child: FractionallySizedBox(
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _confirmDeleteCategory(
                          context,
                          categoryId,
                          categoryName,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
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
                      lastDate: DateTime(2100),

                      builder: (context, child) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;

                        return Theme(
                          data: (isDark ? ThemeData.dark() : ThemeData.light())
                              .copyWith(
                                colorScheme: ColorScheme.fromSeed(
                                  seedColor: Colors
                                      .teal, // ganti ungu default jadi teal
                                  brightness: isDark
                                      ? Brightness.dark
                                      : Brightness.light,
                                ),

                                datePickerTheme: DatePickerThemeData(
                                  headerBackgroundColor: Colors.teal,
                                  headerForegroundColor: Colors.white,

                                  todayForegroundColor: WidgetStatePropertyAll(
                                    Colors.teal,
                                  ),

                                  dayForegroundColor:
                                      WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return Colors.white;
                                        }
                                        return isDark
                                            ? Colors.white
                                            : Colors.black;
                                      }),

                                  dayBackgroundColor:
                                      WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return Colors.teal;
                                        }
                                        return null;
                                      }),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
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

void _showAddCategoryDialog(BuildContext context, String type) {
  final colors = Theme.of(context).colorScheme;

  final nameC = TextEditingController();

  Get.bottomSheet(
    SafeArea(
      bottom: true,
      child: FractionallySizedBox(
        heightFactor: 0.4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.secondary, // 🔥 fix warna (tadi salah pakai tertiary)
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Text(
                "Tambah Kategori",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.tertiary,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: nameC,
                style: TextStyle(color: colors.tertiary), // 🔥 warna teks
                cursorColor: colors.tertiary,
                decoration: InputDecoration(
                  hintText: "Nama kategori",
                  hintStyle: TextStyle(color: colors.tertiary),

                  filled: true,
                  fillColor: colors.secondary,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.tertiary),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.tertiary, width: 1.5),
                  ),
                ),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () async {
                  final randomColor = getRandomColorHex();

                  await FirebaseFirestore.instance.collection('categories').add(
                    {
                      'name': nameC.text,
                      'icon': 'category', // 🔥 default icon
                      'color': randomColor, // 🔥 random warna
                      'type': type,
                    },
                  );

                  Get.back();

                  showSnack(
                    title: "Sukses",
                    message: "Kategori berhasil ditambahkan",
                  );
                },
                child: Text(
                  "Simpan",
                  style: TextStyle(color: colors.inverseSurface),
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

String getRandomColorHex() {
  final random = Random();
  return '#${(random.nextInt(0xFFFFFF)).toRadixString(16).padLeft(6, '0')}';
}
