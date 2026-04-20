import 'package:fintrack/controllers/laporan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final controller = Get.put(LaporanController());

    return StreamBuilder(
      stream: controller.transaksiStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        controller.calculate(docs);

        return Obx(() {
          final totalSaldo =
              controller.totalIncome.value - controller.totalExpense.value;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔥 TOTAL SALDO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Total Saldo",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Rp ${NumberFormat.decimalPattern('id').format(totalSaldo)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 PEMASUKAN & PENGELUARAN
                Row(
                  children: [
                    Expanded(
                      child: _card(
                        "Pemasukan",
                        controller.totalIncome.value,
                        Colors.green,
                        context,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _card(
                        "Pengeluaran",
                        controller.totalExpense.value,
                        Colors.red,
                        context,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔥 SUMMARY PER KATEGORI
                Expanded(
                  child: ListView(
                    children: controller.categorySummary.entries.map((e) {
                      return _listItem(e.key, e.value, context);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _card(String title, int amount, Color color, BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: colors.tertiary)),
          const SizedBox(height: 6),
          Text(
            "Rp ${NumberFormat.decimalPattern('id').format(amount)}",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listItem(String title, int amount, BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: colors.tertiary)),
      trailing: Text(
        "Rp ${NumberFormat.decimalPattern('id').format(amount)}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: colors.tertiary,
        ),
      ),
    );
  }
}
