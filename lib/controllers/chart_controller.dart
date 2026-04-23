import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChartController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var income = 0.0.obs;
  var expense = 0.0.obs;
  var isLoading = true.obs;
  var touchedIndex = (-1).obs;

  Map<String, dynamic> categoryMap = {};

  @override
  void onInit() {
    super.onInit();
    listenData(); // 🔥 realtime
  }

  void listenData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // ambil category sekali
    final categorySnapshot = await firestore.collection('categories').get();
    for (var doc in categorySnapshot.docs) {
      categoryMap[doc.id] = doc.data();
    }

    firestore
        .collection('users')
        .doc(uid)
        .collection('transactions ')
        .snapshots()
        .listen((snapshot) {
          double totalIncome = 0;
          double totalExpense = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();

            final amount = (data['amount'] ?? 0).toDouble();
            final categoryId = data['category'];

            final category = categoryMap[categoryId];
            final type = category?['type'];

            if (type == 'pemasukan') {
              totalIncome += amount;
            } else {
              totalExpense += amount;
            }
          }

          income.value = totalIncome;
          expense.value = totalExpense;
          isLoading.value = false;
        });
  }
}
