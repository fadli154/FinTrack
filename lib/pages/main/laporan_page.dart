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

    return Scaffold(
      appBar: AppBar(toolbarHeight: 3, backgroundColor: colors.secondary),

      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        child: StreamBuilder(
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

              return ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                      ],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // 🔥 penting!
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: colors.primary,
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 40,
                              color: colors.inverseSurface,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.center, // 🔥 center text
                            children: [
                              Text(
                                "Saldo",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.inversePrimary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Rp ${NumberFormat.decimalPattern('id').format(totalSaldo)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.inversePrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),

                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // 🔥 PEMASUKAN & PENGELUARAN
                        Row(
                          children: [
                            Expanded(
                              child: _card(
                                "Pemasukan",
                                controller.totalIncome.value,
                                Colors.green,
                                Icons.arrow_downward,
                                context,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _card(
                                "Pengeluaran",
                                controller.totalExpense.value,
                                Colors.red,
                                Icons.arrow_upward,
                                context,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // 🔥 TITLE
                        Text(
                          "Ringkasan Kategori",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.tertiary,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🔥 LIST KATEGORI
                        ...controller.categorySummary.entries.map((e) {
                          return _listItem(e.key, e.value, context);
                        }),
                      ],
                    ),
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }

  Widget _card(
    String title,
    int amount,
    Color color,
    IconData icon,
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .1), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 7),
          Text(title, style: TextStyle(color: colors.tertiary)),
          const SizedBox(height: 7),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.inversePrimary.withValues(alpha: .2),
            child: Icon(Icons.category, color: colors.inversePrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(color: colors.tertiary)),
          ),
          Text(
            "Rp ${NumberFormat.decimalPattern('id').format(amount)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
