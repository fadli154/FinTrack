import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/controllers/home_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LaporanController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  // 🔥 ambil categoryMap dari HomeController
  late final HomeController homeController;

  var totalIncome = 0.obs;
  var totalExpense = 0.obs;

  var categorySummary = <String, int>{}.obs;

  // 🔥 stream transaksi
  Stream<QuerySnapshot<Map<String, dynamic>>> get transaksiStream => firestore
      .collection('users')
      .doc(userId)
      .collection('transactions ')
      .snapshots();

  @override
  void onInit() {
    super.onInit();

    homeController = Get.find<HomeController>();

    // ⚠️ pastikan categories sudah didengarkan
    homeController.listenCategories();
  }

  // 🔥 helper ambil category data
  Map<String, dynamic>? getCategory(String? categoryId) {
    if (categoryId == null) return null;
    return homeController.categoryMap[categoryId];
  }

  // 🔥 core logic laporan
  void calculate(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    int income = 0;
    int expense = 0;

    Map<String, int> summary = {};

    for (var doc in docs) {
      final data = doc.data();

      final amount = (data['amount'] as num?) ?? 0;
      final categoryId = data['category'];

      final categoryData = getCategory(categoryId);

      final type = categoryData?['type']; // 🔥 ambil dari categories
      final categoryName = categoryData?['name'] ?? 'Other';

      // 🔥 hitung income / expense
      if (type == 'pemasukan') {
        income += amount.toInt();
      } else if (type == 'pengeluaran') {
        expense += amount.toInt();
      } else {
        // fallback kalau belum ada category
        expense += amount.toInt();
      }

      // 🔥 summary per kategori
      summary[categoryName] = (summary[categoryName] ?? 0) + amount.toInt();
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    categorySummary.value = summary;
  }
}
