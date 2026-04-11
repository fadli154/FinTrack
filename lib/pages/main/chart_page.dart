import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pengeluaran",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.tertiary,
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 CARD CHART
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      color: Colors.red,
                      title: "40%",
                    ),
                    PieChartSectionData(
                      value: 30,
                      color: Colors.blue,
                      title: "30%",
                    ),
                    PieChartSectionData(
                      value: 20,
                      color: Colors.green,
                      title: "20%",
                    ),
                    PieChartSectionData(
                      value: 10,
                      color: Colors.orange,
                      title: "10%",
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 LEGEND
          _legendItem("Makanan", Colors.red),
          _legendItem("Transport", Colors.blue),
          _legendItem("Belanja", Colors.green),
          _legendItem("Lainnya", Colors.orange),
        ],
      ),
    );
  }

  Widget _legendItem(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }
}
