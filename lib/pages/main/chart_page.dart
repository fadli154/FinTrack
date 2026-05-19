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

                    const SizedBox(height: 8),

                    Text(
                      "Menampilkan: ${controller.periodLabel}",
                      style: TextStyle(
                        color: colors.tertiary.withValues(alpha: .75),
                        fontSize: 12,
                      ),
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

                    const SizedBox(height: 16),

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Income vs Expense",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.tertiary,
                            ),
                          ),

                          const SizedBox(height: 25),

                          _modernBar(
                            title: "Pemasukan",
                            value: income,
                            total: total,
                            color: Colors.green,
                            currency: currency,
                          ),

                          const SizedBox(height: 20),

                          _modernBar(
                            title: "Pengeluaran",
                            value: expense,
                            total: total,
                            color: Colors.red,
                            currency: currency,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _statsCard(
                              "Income Ratio",
                              "${controller.incomeExpenseRatio.toStringAsFixed(1)}%",
                              Icons.account_balance_wallet,
                              Colors.cyan,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _statsCard(
                              "Expense Ratio",
                              "${controller.expenseRatio.toStringAsFixed(1)}%",
                              Icons.pie_chart,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

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

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            "Net Balance",
                            controller.netCashflow,
                            controller.netCashflow >= 0
                                ? Colors.teal
                                : Colors.red,
                            controller.netCashflow >= 0
                                ? Icons.account_balance_wallet
                                : Icons.warning,
                            currency,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _statsCard(
                            controller.healthStatus,
                            "${controller.financialHealthScore.toStringAsFixed(0)}/100",
                            Icons.favorite,
                            controller.financialHealthScore >= 80
                                ? Colors.green
                                : controller.financialHealthScore >= 60
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Trend Bulanan",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.tertiary,
                                ),
                              ),
                              Text(
                                controller.periodLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.tertiary.withValues(alpha: .7),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Pergerakan pemasukan dan pengeluaran per bulan",
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.tertiary.withValues(alpha: .6),
                            ),
                          ),

                          const SizedBox(height: 18),

                          if (controller.monthlyLabels.length < 2)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: .08),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.show_chart,
                                    size: 48,
                                    color: Colors.grey.withValues(alpha: .7),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Data belum cukup untuk trend bulanan",
                                    style: TextStyle(
                                      color: colors.tertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Coba pilih filter All Time atau rentang tanggal yang lebih panjang",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.tertiary.withValues(
                                        alpha: .6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              height: 280,
                              child: LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: (controller.monthlyLabels.length - 1)
                                      .toDouble(),
                                  minY: 0,
                                  maxY: controller.trendMaxY,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval:
                                        controller.trendMaxY / 4,
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineTouchData: LineTouchData(
                                    handleBuiltInTouches: true,
                                  ),
                                  titlesData: FlTitlesData(
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 44,
                                        interval: controller.trendMaxY / 4,
                                        getTitlesWidget: (value, meta) {
                                          if (value == 0) {
                                            return Text(
                                              "0",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: colors.tertiary
                                                    .withValues(alpha: .7),
                                              ),
                                            );
                                          }

                                          return Text(
                                            NumberFormat.compact(
                                              locale: 'id',
                                            ).format(value),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: colors.tertiary.withValues(
                                                alpha: .7,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();

                                          if (index < 0 ||
                                              index >=
                                                  controller
                                                      .monthlyLabels
                                                      .length) {
                                            return const SizedBox.shrink();
                                          }

                                          if (controller.monthlyLabels.length >
                                                  6 &&
                                              index.isOdd) {
                                            return const SizedBox.shrink();
                                          }

                                          return SideTitleWidget(
                                            meta: meta,
                                            child: Text(
                                              controller.monthlyLabels[index],
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colors.tertiary
                                                    .withValues(alpha: .75),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                        controller.monthlyIncomeValues.length,
                                        (i) => FlSpot(
                                          i.toDouble(),
                                          controller.monthlyIncomeValues[i],
                                        ),
                                      ),
                                      isCurved: true,
                                      color: Colors.green,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.green.withValues(
                                          alpha: .12,
                                        ),
                                      ),
                                    ),
                                    LineChartBarData(
                                      spots: List.generate(
                                        controller.monthlyExpenseValues.length,
                                        (i) => FlSpot(
                                          i.toDouble(),
                                          controller.monthlyExpenseValues[i],
                                        ),
                                      ),
                                      isCurved: true,
                                      color: Colors.red,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.red.withValues(
                                          alpha: .12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _trendLegend(
                                  "Pemasukan",
                                  Colors.green,
                                  context,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _trendLegend(
                                  "Pengeluaran",
                                  Colors.red,
                                  context,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _trendLegend(String title, Color color, BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernBar({
    required String title,
    required double value,
    required double total,
    required Color color,
    required NumberFormat currency,
  }) {
    final double percent = total == 0 ? 0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),

            Text(
              currency.format(value),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 14,
            backgroundColor: Colors.grey.withValues(alpha: .15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),

        const SizedBox(height: 6),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${(percent * 100).toStringAsFixed(1)}%",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _statsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),

          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
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
