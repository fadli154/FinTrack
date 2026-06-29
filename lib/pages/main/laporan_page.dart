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
      locale: Get.locale?.languageCode ?? 'id',
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
                              "report_title".tr,
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
                          "report_showing".trParams({'period': controller.periodLabel}),
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
                                "filter_all_time".tr,
                                ReportFilter.all,
                                controller,
                                context,
                              ),
                              _filterChip(
                                "filter_today".tr,
                                ReportFilter.today,
                                controller,
                                context,
                              ),
                              _filterChip(
                                "filter_month".tr,
                                ReportFilter.month,
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
                                            ReportFilter.custom
                                        ? Colors.teal
                                        : Colors.grey.withValues(alpha: .15),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "filter_custom".tr,
                                    style: TextStyle(
                                      color:
                                          controller.selectedFilter.value ==
                                              ReportFilter.custom
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
                                      "income".tr,
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
                                      "expense".tr,
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
                                      "balance".tr,
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
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .08),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.trending_down,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      currency.format(controller.averageIncome),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "average_income".tr,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey.withValues(alpha: .2),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.trending_up,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      currency.format(
                                        controller.averageExpense,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "average_expense".tr,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .08),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.receipt_long,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${controller.totalTransactionCount}",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: colors.tertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "total_transactions".tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.tertiary.withValues(
                                          alpha: .7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 70,
                                color: Colors.grey.withValues(alpha: .2),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.analytics_outlined,
                                      color: Colors.orange,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currency.format(
                                        controller.averageTransaction,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: colors.tertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "average_amount".tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.tertiary.withValues(
                                          alpha: .7,
                                        ),
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
                            "category_summary".tr,
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
                                const Icon(
                                  Icons.inbox_outlined,
                                  size: 72,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "empty_reports".tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.tertiary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "change_filter_hint".tr,
                                  style: const TextStyle(color: Colors.grey),
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
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "transaction_history".tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.tertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (controller.transactionGroups.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text("no_transactions".tr),
                            ),
                          )
                        else
                          ...controller.displayedTransactionGroups.map((group) {
                            final transactions =
                                group['transactions']
                                    as List<Map<String, dynamic>>;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.secondary,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        group['date'].toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: colors.tertiary,
                                        ),
                                      ),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "+ ${currency.format(group['income'])}",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "- ${currency.format(group['expense'])}",
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  Divider(
                                    color: Colors.grey.withValues(alpha: .3),
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: 14),

                                  ...transactions.map((trx) {
                                    final isIncome = trx['type'] == 'pemasukan';

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: isIncome
                                                  ? Colors.green.withValues(
                                                      alpha: .12,
                                                    )
                                                  : Colors.red.withValues(
                                                      alpha: .12,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              isIncome
                                                  ? Icons.south_west
                                                  : Icons.north_east,
                                              color: isIncome
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  trx['title'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: colors.tertiary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  trx['category'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: colors.tertiary
                                                        .withValues(alpha: .65),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            "${isIncome ? '+' : '-'} ${currency.format(trx['amount'])}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isIncome
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),

                        if (controller.hasMoreData)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.loadMoreTransactions,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  "load_more".tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
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
                        title: 'financial_report'.tr,
                      );

                      Get.back();

                      await Printing.sharePdf(
                        bytes: bytes,
                        filename: 'pdf_filename'.tr,
                      );
                    } catch (e) {
                      Get.back();

                      Get.snackbar(
                        "error".tr,
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
    ReportFilter value,
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
              isIncome ? 'income'.tr : 'expense'.tr,
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
              locale: Get.locale?.languageCode ?? 'id',
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
