import 'package:fintrack/controllers/chart_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final controller = Get.put(ChartController());

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

          final income = controller.income.value;
          final expense = controller.expense.value;
          final total = income + expense;
          final totalSaldo = income - expense;
          final isEmpty = total == 0;

          return ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.secondary,
                      colors.secondary.withValues(alpha: 0.9),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
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
                          Icons.pie_chart_sharp,
                          size: 32,
                          color: totalSaldo >= 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Statistik",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: totalSaldo >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 25),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip("All Time", "all", controller, context),
                          _filterChip("Hari Ini", "today", controller, context),
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

                                            todayForegroundColor:
                                                WidgetStatePropertyAll(
                                                  Colors.teal,
                                                ),

                                            dayForegroundColor:
                                                WidgetStateProperty.resolveWith(
                                                  (states) {
                                                    if (states.contains(
                                                      WidgetState.selected,
                                                    )) {
                                                      return Colors.white;
                                                    }

                                                    return isDark
                                                        ? Colors.white
                                                        : Colors.black;
                                                  },
                                                ),

                                            dayBackgroundColor:
                                                WidgetStateProperty.resolveWith(
                                                  (states) {
                                                    if (states.contains(
                                                      WidgetState.selected,
                                                    )) {
                                                      return Colors.teal;
                                                    }
                                                    return null;
                                                  },
                                                ),

                                            rangeSelectionBackgroundColor:
                                                Colors.teal.withValues(
                                                  alpha: .25,
                                                ),

                                            rangeSelectionOverlayColor:
                                                WidgetStatePropertyAll(
                                                  Colors.teal.withValues(
                                                    alpha: .15,
                                                  ),
                                                ),

                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                    controller.selectedFilter.value == 'custom'
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
                            color: Colors.black.withValues(alpha: .1),
                            blurRadius: 10,
                          ),
                        ],
                      ),

                      child: isEmpty
                          ? Column(
                              children: [
                                const SizedBox(height: 40),

                                Icon(
                                  Icons.pie_chart_outline,
                                  size: 80,
                                  color: Colors.grey,
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  "Belum ada data pada filter ini",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colors.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "Coba ganti filter tanggal",
                                  style: TextStyle(color: Colors.grey),
                                ),

                                const SizedBox(height: 40),
                              ],
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: 240,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 65,
                                      pieTouchData: PieTouchData(
                                        touchCallback: (event, response) {
                                          if (response != null &&
                                              response.touchedSection != null) {
                                            controller.touchedIndex.value =
                                                response
                                                    .touchedSection!
                                                    .touchedSectionIndex;
                                          }
                                        },
                                      ),

                                      sections: List.generate(2, (i) {
                                        final isTouched =
                                            i == controller.touchedIndex.value;

                                        final value = i == 0 ? income : expense;

                                        final percent = total == 0
                                            ? 0
                                            : (value / total) * 100;

                                        return PieChartSectionData(
                                          value: value,
                                          color: i == 0
                                              ? Colors.green
                                              : Colors.red,
                                          radius: isTouched ? 60 : 50,
                                          title:
                                              "${percent.toStringAsFixed(1)}%",
                                          titleStyle: TextStyle(
                                            fontSize: isTouched ? 16 : 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                _legend(
                                  "Pemasukan",
                                  income,
                                  Colors.green,
                                  currency,
                                  context,
                                ),

                                _legend(
                                  "Pengeluaran",
                                  expense,
                                  Colors.red,
                                  currency,
                                  context,
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            "Pemasukan",
                            income,
                            Colors.green,
                            Icons.arrow_downward,
                            currency,
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
                          ),
                        ),
                      ],
                    ),
                  ],
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
    ChartController controller,
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

  Widget _legend(
    String title,
    double value,
    Color color,
    NumberFormat currency,
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: colors.tertiary)),
            ],
          ),
          Text(
            currency.format(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String title,
    double value,
    Color color,
    IconData icon,
    NumberFormat currency,
  ) {
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
          Text(title),
          const SizedBox(height: 6),
          Text(
            currency.format(value),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
