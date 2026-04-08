import 'package:fintrack/controllers/home_controller.dart';
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

                ...items.map((data) {
                  final categoryId = data['category'];
                  final categoryData = controller.categoryMap[categoryId];
                  final categoryName = categoryData?['name'] ?? 'Other';

                  final iconName = categoryData?['icon'] ?? 'attach_money';
                  final colorHex = categoryData?['color'] ?? '#9E9E9E';
                  final isIncome = categoryData?['type'] == 'pemasukan';
                  final amount = (data['amount'] as num?) ?? 0;

                  return Container(
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
                                message: data['note'] ?? '',
                                child: Text(
                                  controller.capitalizeEachWord(
                                    data['note'] ?? '',
                                  ),
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
                  );
                }),
              ],
            );
          },
        );
      },
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
