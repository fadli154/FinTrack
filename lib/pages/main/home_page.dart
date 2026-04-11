import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fintrack/controllers/add_controller.dart';
import 'package:fintrack/controllers/home_controller.dart';
import 'package:fintrack/services/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final controller = Get.put(HomeController());

    if (controller.user == null) {
      return const Center(child: Text("User belum login"));
    }

    return StreamBuilder(
      stream: controller.transaksiStream,
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

        final groupedData = controller.groupByDate(docs);
        final keys = groupedData.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: keys.length,
          itemBuilder: (context, index) {
            final dateKey = keys[index];
            final items = groupedData[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER TANGGAL
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    dateKey,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.tertiary,
                    ),
                  ),
                ),

                ...items.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final docId = doc.id; // 🔥 ini kunci utama
                  final categoryId = data['category'];
                  final categoryData = controller.categoryMap[categoryId];
                  final categoryName = categoryData?['name'] ?? 'Other';
                  final note = data['note'];

                  final displayText =
                      (note != null && note.toString().trim().isNotEmpty)
                      ? note
                      : categoryName;

                  final iconName = categoryData?['icon'] ?? 'attach_money';
                  final colorHex = categoryData?['color'] ?? '#9E9E9E';
                  final isIncome = categoryData?['type'] == 'pemasukan';
                  final amount = (data['amount'] as num?) ?? 0;

                  return GestureDetector(
                    onTap: () {
                      _showDetailDialog(context, data, categoryData, docId);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.secondary.withAlpha(50),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.tertiary.withValues(alpha: .1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: controller.getColorFromHex(colorHex),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.getIconFromString(iconName),
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔥 TITLE TRANSAKSI (note user)
                                Text(
                                  controller.capitalizeEachWord(categoryName),
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.tertiary.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Tooltip(
                                  message: displayText,
                                  child: Text(
                                    controller.capitalizeEachWord(displayText),
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        color: colors.tertiary.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                              color: colors.tertiary.withValues(alpha: 0.5),
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
      },
    );
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
      Container(
        padding: const EdgeInsets.all(20),
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
                        btnOkText: "Hapus",
                        btnOkColor: Colors.red,
                        btnOkOnPress: () async {
                          try {
                            await controller.deleteTransaction(docId);
                            Get.back();

                            Get.snackbar(
                              "Sukses",
                              "Transaksi berhasil dihapus",
                            );
                          } catch (e) {
                            Get.snackbar("Error", e.toString());
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
      isScrollControlled: true,
    );
  }

  void _showEditDialog(
    BuildContext context,
    Map<String, dynamic> data, [
    docId,
  ]) {
    final colors = Theme.of(context).colorScheme;
    final controller = Get.put(AddController());

    final amountC = TextEditingController(text: data['amount'].toString());
    final noteC = TextEditingController(text: data['note']);

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
                  await controller.updateTransaction(
                    id: docId,
                    amount: int.parse(amountC.text),
                    note: noteC.text,
                  );
                  Get.back();
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
