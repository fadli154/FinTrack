import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("User belum login"));
    }

    final transaksiRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection("transactions ")
        .orderBy("date", descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: transaksiRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        print(snapshot.data?.docs);

        if (docs.isEmpty) {
          return _emptyState(colors);
        }

        final groupedData = groupByDate(docs);
        final keys = groupedData.keys.toList();

        return Container(
          color: const Color(0xFFF5F5F5),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final dateKey = keys[index];
              final items = groupedData[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 HEADER TANGGAL
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      dateKey,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // 🔥 LIST ITEM DALAM TANGGAL
                  ...items.map((data) {
                    final isIncome = data['type'] == 'income';
                    final amount = (data['amount'] as num?) ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          // ICON
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  data['category'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // AMOUNT
                          Text(
                            "${isIncome ? '+' : '-'} Rp ${NumberFormat.decimalPattern('id').format(amount)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
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
            color: colors.tertiary.withOpacity(0.4),
          ),
          const SizedBox(height: 15),
          Text(
            'Tidak ada catatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.tertiary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, List<Map<String, dynamic>>> groupByDate(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  Map<String, List<Map<String, dynamic>>> grouped = {};

  for (var doc in docs) {
    final data = doc.data();

    final timestamp = data['date'] as Timestamp?;
    if (timestamp == null) continue;

    final date = timestamp.toDate();
    final key = DateFormat('d MMM', 'id').format(date);

    if (!grouped.containsKey(key)) {
      grouped[key] = [];
    }

    grouped[key]!.add(data);
  }

  return grouped;
}
