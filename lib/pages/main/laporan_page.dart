import 'package:fintrack/controllers/laporan_controller.dart';
import 'package:fintrack/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class LaporanPage extends StatelessWidget {
  LaporanPage({super.key});

  final controller = Get.put(LaporanController());

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(toolbarHeight: 3, backgroundColor: colors.secondary),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final income = controller.totalIncome.value;
          final expense = controller.totalExpense.value;
          final balance = controller.totalBalance;
          final isEmpty = controller.isEmpty;
          final entries = controller.sortedCategoryEntries;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 110),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.secondary,
                          colors.secondary.withValues(alpha: 0.92),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                        ),
                      ],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 30,
                              color: balance >= 0 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Laporan",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: balance >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Menampilkan: ${controller.periodLabel}",
                          style: TextStyle(
                            color: colors.tertiary.withValues(alpha: .75),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterChip(
                                "All Time",
                                "all",
                                controller,
                                context,
                              ),
                              _filterChip(
                                "Hari Ini",
                                "today",
                                controller,
                                context,
                              ),
                              _filterChip(
                                "Bulan Ini",
                                "month",
                                controller,
                                context,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      final isDark =
                                          Theme.of(context).brightness ==
                                          Brightness.dark;

                                      return Theme(
                                        data:
                                            (isDark
                                                    ? ThemeData.dark()
                                                    : ThemeData.light())
                                                .copyWith(
                                                  colorScheme:
                                                      ColorScheme.fromSeed(
                                                        seedColor: Colors.teal,
                                                        brightness: isDark
                                                            ? Brightness.dark
                                                            : Brightness.light,
                                                      ),
                                                  datePickerTheme: DatePickerThemeData(
                                                    headerBackgroundColor:
                                                        Colors.teal,
                                                    headerForegroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                  ),
                                                  textButtonTheme:
                                                      TextButtonThemeData(
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.teal,
                                                            ),
                                                      ),
                                                ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (picked != null) {
                                    controller.setCustomDate(
                                      picked.start,
                                      picked.end,
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        controller.selectedFilter.value ==
                                            'custom'
                                        ? Colors.teal
                                        : Colors.grey.withValues(alpha: .15),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "Custom",
                                    style: TextStyle(
                                      color:
                                          controller.selectedFilter.value ==
                                              'custom'
                                          ? Colors.white
                                          : colors.tertiary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .08),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _summaryCard(
                                      "Pemasukan",
                                      income,
                                      Colors.green,
                                      Icons.arrow_downward,
                                      currency,
                                      context,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _summaryCard(
                                      "Pengeluaran",
                                      expense,
                                      Colors.red,
                                      Icons.arrow_upward,
                                      currency,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: .08),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Saldo",
                                      style: TextStyle(
                                        color: colors.tertiary.withValues(
                                          alpha: .75,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      currency.format(balance),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: balance >= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Ringkasan Kategori",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.tertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: colors.secondary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .06),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 18),
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 72,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Belum ada data pada filter ini",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.tertiary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Coba ubah filter tanggalnya",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 18),
                              ],
                            ),
                          )
                        else
                          ...entries.map((e) {
                            return _listItem(
                              e['name'].toString(),
                              e['amount'] as int,
                              e['type']?.toString() ?? 'pengeluaran',
                              context,
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 18,
                bottom: MediaQuery.of(context).padding.bottom + 20,
                child: GestureDetector(
                  onTap: () async {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    try {
                      final bytes = await PdfService.generateLaporanPdf(
                        totalIncome: controller.totalIncome.value,
                        totalExpense: controller.totalExpense.value,
                        categorySummary: controller.categorySummary,
                        reportDate: DateTime.now(),
                        periodLabel: controller.periodLabel,
                        title: 'Laporan Keuangan',
                      );

                      Get.back();

                      await Printing.sharePdf(
                        bytes: bytes,
                        filename: 'laporan_keuangan.pdf',
                      );
                    } catch (e) {
                      Get.back();

                      Get.snackbar(
                        "Error",
                        e.toString(),
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Container(
                    height: 62,
                    width: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.orange],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _filterChip(
    String title,
    String value,
    LaporanController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == value;
      final colors = Theme.of(context).colorScheme;

      return GestureDetector(
        onTap: () => controller.changeFilter(value),
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.teal
                : Colors.grey.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : colors.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  Widget _summaryCard(
    String title,
    int value,
    Color color,
    IconData icon,
    NumberFormat currency,
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: colors.tertiary)),
          const SizedBox(height: 6),
          Text(
            currency.format(value),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _listItem(
    String title,
    int amount,
    String type,
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isIncome = type == 'pemasukan';

    final bgColor = isIncome
        ? Colors.green.withValues(alpha: .10)
        : Colors.red.withValues(alpha: .10);
    final iconBg = isIncome
        ? Colors.green.withValues(alpha: .18)
        : Colors.red.withValues(alpha: .18);
    final accent = isIncome ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconBg,
            child: Icon(Icons.category, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isIncome ? 'Pemasukan' : 'Pengeluaran',
              style: TextStyle(
                fontSize: 11,
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(amount),
            style: TextStyle(fontWeight: FontWeight.bold, color: accent),
          ),
        ],
      ),
    );
  }
}
