import 'package:flutter/material.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔥 TOTAL CARD
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
                const Text(
                  "Rp 12.500.000",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 INCOME & EXPENSE
          Row(
            children: [
              Expanded(
                child: _card("Pemasukan", "Rp 8.000.000", Colors.green, colors),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _card("Pengeluaran", "Rp 4.500.000", Colors.red, colors),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🔥 LIST SUMMARY
          Expanded(
            child: ListView(
              children: [
                _listItem("Makanan", "Rp 1.200.000"),
                _listItem("Transport", "Rp 800.000"),
                _listItem("Belanja", "Rp 1.500.000"),
                _listItem("Hiburan", "Rp 1.000.000"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, String amount, Color color, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _listItem(String title, String amount) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
