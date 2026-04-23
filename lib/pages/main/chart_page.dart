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

          if (total == 0) {
            return const Center(child: Text("Belum ada data"));
          }

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colors.primary,
                      child: Icon(
                        Icons.pie_chart_sharp,
                        size: 28,
                        color: colors.inverseSurface,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Statistik",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: totalSaldo >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),

                child: Column(
                  children: [
                    // 🔥 PIE CHART CARD
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
                                      controller.touchedIndex.value = response
                                          .touchedSection!
                                          .touchedSectionIndex;
                                    }
                                  },
                                ),
                                sections: List.generate(2, (i) {
                                  final isTouched =
                                      i == controller.touchedIndex.value;

                                  final value = i == 0 ? income : expense;
                                  final percent = (value / total) * 100;

                                  return PieChartSectionData(
                                    value: value,
                                    color: i == 0 ? Colors.green : Colors.red,
                                    radius: isTouched ? 60 : 50,
                                    title: "${percent.toStringAsFixed(0)}%",
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

                          // 🔥 LEGEND
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

                    // 🔥 SUMMARY CARD
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
