import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fintrack/controllers/add_controller.dart';
import 'package:fintrack/controllers/home_controller.dart';
import 'package:fintrack/partials/my_drawer.dart';
import 'package:fintrack/services/currency_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MyHomePage extends StatelessWidget {
  final String title;
  final controller = Get.find<HomeController>();

  MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Obx(() {
          final monthFormat = DateFormat('MMM', 'id_ID');
          final year = controller.selectedDate.value.year;
          final month = monthFormat.format(controller.selectedDate.value);

          return GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),

                builder: (context, child) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

                  return Theme(
                    data: (isDark ? ThemeData.dark() : ThemeData.light())
                        .copyWith(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor:
                                Colors.teal, // ganti ungu default jadi teal
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

                            dayForegroundColor: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }
                                return isDark ? Colors.white : Colors.black;
                              },
                            ),

                            dayBackgroundColor: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.teal;
                                }
                                return null;
                              },
                            ),

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
                controller.selectedDate.value = picked;
                controller.startDate.value = null;
                controller.endDate.value = null;
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$year",
                  style: TextStyle(fontSize: 12, color: colors.inverseSurface),
                ),
                Row(
                  children: [
                    Text(
                      month,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.inverseSurface,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.inverseSurface,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => controller.toggleDrawer(),
          color: colors.inverseSurface,
        ),
        actions: [
          // 🔥 DATE RANGE
          IconButton(
            icon: const Icon(Icons.date_range),
            color: colors.inverseSurface,
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime(2100),

                builder: (context, child) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

                  return Theme(
                    data: (isDark ? ThemeData.dark() : ThemeData.light())
                        .copyWith(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: Colors.teal,
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

                            dayForegroundColor: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }

                                return isDark ? Colors.white : Colors.black;
                              },
                            ),

                            dayBackgroundColor: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.teal;
                                }
                                return null;
                              },
                            ),

                            rangeSelectionBackgroundColor: Colors.teal
                                .withValues(alpha: .25),

                            rangeSelectionOverlayColor: WidgetStatePropertyAll(
                              Colors.teal.withValues(alpha: .15),
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.teal,
                            ),
                          ),
                        ),

                    child: child!,
                  );
                },
              );

              if (picked != null) {
                controller.startDate.value = picked.start;
                controller.endDate.value = picked.end;
              }

              if (picked != null) {
                controller.startDate.value = picked.start;
                controller.endDate.value = picked.end;
              }
            },
          ),

          // 🔥 SEARCH
          IconButton(
            icon: const Icon(Icons.search),
            color: colors.inverseSurface,
            onPressed: () {
              Get.bottomSheet(_buildSearchSheet(controller, context));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Stack(
          children: [
            _buildContent(colors),

            // 🔥 DRAWER ONLY
            Obx(() {
              return Stack(
                children: [
                  if (controller.isTopDrawerOpen.value)
                    GestureDetector(
                      onTap: controller.closeDrawer,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    top: controller.isTopDrawerOpen.value ? 0 : -300,
                    left: 0,
                    right: 0,
                    child: const TopDrawerContent(),
                  ),
                ],
              );
            }),

            Positioned(
              right: 18,
              bottom: 20,

              child: GestureDetector(
                onTap: () {
                  _showAddModal(context);
                },

                child: Container(
                  height: 62,
                  width: 62,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: LinearGradient(
                      colors: [Colors.teal, Colors.tealAccent],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .25),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Icon(
                    Icons.add_circle_sharp,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // ⏳ loading auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ belum login
        if (!authSnapshot.hasData) {
          return const Center(child: Text("User belum login"));
        }

        return Obx(
          () => StreamBuilder(
            key: ValueKey(
              "${controller.selectedDate.value.month}-"
              "${controller.selectedDate.value.year}-"
              "${controller.startDate.value}-"
              "${controller.endDate.value}",
            ),
            stream: controller.getTransaksiStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return _emptyState(colors);
              }

              return Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      final query = controller.searchQuery.value.toLowerCase();

                      // 🔥 FILTER DI AWAL (INI KUNCINYA)
                      final filteredDocs = docs.where((doc) {
                        final data = doc.data();
                        final note = data['note'] ?? '';
                        return note.toString().toLowerCase().contains(query);
                      }).toList();

                      // 🔥 BARU DI GROUP SETELAH FILTER
                      final groupedData = controller.groupByDate(filteredDocs);
                      final totals = controller.sumIncomeByDate(groupedData);
                      final keys = groupedData.keys.toList();

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: keys.length,
                        itemBuilder: (context, index) {
                          final dateKey = keys[index];
                          final items = groupedData[dateKey]!;

                          final filteredItems = items;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER TANGGAL
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateKey,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colors.tertiary,
                                      ),
                                    ),
                                    Text(
                                      "Pemasukan: Rp ${NumberFormat.decimalPattern('id').format(totals[dateKey] ?? 0)}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              ...filteredItems.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final docId = doc.id; // 🔥 ini kunci utama
                                final categoryId = data['category'];
                                final categoryData =
                                    controller.categoryMap[categoryId];
                                final categoryName =
                                    categoryData?['name'] ?? 'Other';
                                final note = data['note'];

                                final displayText =
                                    (note != null &&
                                        note.toString().trim().isNotEmpty)
                                    ? note
                                    : categoryName;

                                final iconName =
                                    categoryData?['icon'] ?? 'attach_money';
                                final colorHex =
                                    categoryData?['color'] ?? '#9E9E9E';
                                final isIncome =
                                    categoryData?['type'] == 'pemasukan';
                                final amount = (data['amount'] as num?) ?? 0;

                                return GestureDetector(
                                  onTap: () {
                                    _showDetailDialog(
                                      context,
                                      data,
                                      categoryData,
                                      docId,
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: colors.secondary.withAlpha(50),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: colors.tertiary.withValues(
                                          alpha: .1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: controller.getColorFromHex(
                                              colorHex,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            controller.getIconFromString(
                                              iconName,
                                            ),
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                            size: 18,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 🔥 TITLE TRANSAKSI (note user)
                                              Text(
                                                controller.capitalizeEachWord(
                                                  categoryName,
                                                ),
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: colors.tertiary
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 3),

                                              Tooltip(
                                                message: displayText,
                                                child: Text(
                                                  controller.capitalizeEachWord(
                                                    displayText,
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: colors.tertiary
                                                          .withValues(
                                                            alpha: 0.4,
                                                          ),
                                                    ),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Text(
                                          "${isIncome ? '+' : '-'} Rp ${NumberFormat.decimalPattern('id').format(amount)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: colors.tertiary.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
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
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
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
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 26,
                      ),
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
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
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
                    trailing: Icon(
                      Icons.calendar_today,
                      color: colors.tertiary,
                    ),
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

                                    todayForegroundColor:
                                        WidgetStatePropertyAll(Colors.teal),

                                    dayForegroundColor:
                                        WidgetStateProperty.resolveWith((
                                          states,
                                        ) {
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
                                        WidgetStateProperty.resolveWith((
                                          states,
                                        ) {
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
                                titleTextStyle: TextStyle(
                                  color: colors.tertiary,
                                ),
                                descTextStyle: TextStyle(
                                  color: colors.tertiary,
                                ),
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
      icon: Icon(
        isError ? Icons.error : Icons.check_circle,
        color: Colors.white,
      ),
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
              color:
                  colors.secondary, // 🔥 fix warna (tadi salah pakai tertiary)
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
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
                      borderSide: BorderSide(
                        color: colors.tertiary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                ElevatedButton(
                  onPressed: () async {
                    final randomColor = getRandomColorHex();

                    await FirebaseFirestore.instance
                        .collection('categories')
                        .add({
                          'name': nameC.text,
                          'icon': 'category', // 🔥 default icon
                          'color': randomColor, // 🔥 random warna
                          'type': type,
                        });

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

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> data,
    Map<String, dynamic>? categoryData,
    String docId,
  ) {
    final colors = Theme.of(context).colorScheme;
    final controller = Get.find<HomeController>();

    final categoryName = categoryData?['name'] ?? 'Other';
    final note = data['note'] ?? '-';
    final amount = data['amount'] ?? 0;
    final iconName = categoryData?['icon'] ?? 'attach_money';
    final colorHex = categoryData?['color'] ?? '#9E9E9E';
    final isIncome = categoryData?['type'] == 'pemasukan';

    Get.bottomSheet(
      SafeArea(
        bottom: true,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewPadding.bottom,
          ),
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HANDLE
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // ICON
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: controller.getColorFromHex(colorHex),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.getIconFromString(iconName),
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(height: 15),

              // CATEGORY
              Text(
                controller.capitalizeEachWord(categoryName),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.tertiary,
                ),
              ),

              const SizedBox(height: 8),

              // NOTE
              Text(
                controller.capitalizeEachWord(note),
                style: TextStyle(
                  fontSize: 14,
                  color: colors.tertiary.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 15),

              // AMOUNT
              Text(
                "${isIncome ? '+' : '-'} Rp ${NumberFormat.decimalPattern('id').format(amount)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.tertiary,
                ),
              ),

              const SizedBox(height: 20),

              // BUTTONS
              Row(
                children: [
                  // EDIT
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        _showEditDialog(context, data, docId);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.tertiary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Edit",
                        style: TextStyle(color: colors.tertiary),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // DELETE
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        AwesomeDialog(
                          context: context,

                          dialogType: DialogType.warning,
                          animType: AnimType.scale,
                          dialogBackgroundColor: colors.secondary,
                          titleTextStyle: TextStyle(color: colors.tertiary),
                          descTextStyle: TextStyle(color: colors.tertiary),

                          title: 'Hapus Transaksi',
                          desc: 'Yakin mau hapus transaksi ini?',
                          btnCancelOnPress: () {},
                          btnCancelColor: colors.primary,
                          btnCancel: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              side: BorderSide(color: colors.tertiary),
                            ),
                            onPressed: () => Get.back(),
                            child: Text(
                              "Batal",
                              style: TextStyle(color: colors.tertiary),
                            ),
                          ),
                          btnOkText: "Hapus",
                          btnOkColor: Colors.red,
                          btnOkOnPress: () async {
                            try {
                              await controller.deleteTransaction(docId);

                              showSnack(
                                title: "Sukses",
                                message: "Transaksi berhasil dihapus",
                              );
                            } catch (e) {
                              showSnack(title: "Error", message: e.toString());
                            }
                          },
                        ).show();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Hapus",
                        style: TextStyle(color: colors.inverseSurface),
                      ),
                    ),
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

  void _showEditDialog(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    final colors = Theme.of(context).colorScheme;
    final controller = Get.put(AddController());

    final formattedAmount = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(data['amount']);

    final amountC = TextEditingController(text: formattedAmount);
    final noteC = TextEditingController(text: data['note']);

    Get.bottomSheet(
      SafeArea(
        bottom: true,
        child: FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),

                Text(
                  "Edit Transaksi",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: colors.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: amountC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: colors.tertiary),
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
                const SizedBox(height: 25),
                TextField(
                  controller: noteC,
                  style: const TextStyle(color: Colors.black),

                  decoration: InputDecoration(
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color.fromARGB(213, 245, 245, 245),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    final cleanAmount = int.parse(
                      amountC.text.replaceAll(RegExp(r'[^0-9]'), ''),
                    );

                    await controller.updateTransaction(
                      id: docId,
                      amount: cleanAmount,
                      note: noteC.text,
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
                            "Transaksi berhasil diubah!",
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
                          showSnack(title: "Error", message: e.toString());
                        }
                      },
                    ).show();
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(color: colors.inverseSurface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 80,
            color: colors.tertiary.withValues(alpha: .4),
          ),
          const SizedBox(height: 15),
          Text(
            'Tidak ada catatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.tertiary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
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

Widget _buildSearchSheet(HomeController controller, BuildContext context) {
  final colors = Theme.of(context).colorScheme;

  return SafeArea(
    bottom: true,
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              controller.searchQuery.value = value;
            },
            decoration: InputDecoration(
              hintText: "Cari transaksi",
              hintStyle: TextStyle(color: colors.tertiary),
              filled: true,
              fillColor: const Color.fromARGB(143, 245, 245, 245),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
