import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;

  // 🔥 ambil categories by type
  Stream<QuerySnapshot<Map<String, dynamic>>> getCategories(String type) {
    return FirebaseFirestore.instance
        .collection('categories')
        .where('type', isEqualTo: type)
        .snapshots();
  }

  // 🔥 simpan transaksi
  Future<void> addTransaction({
    required String categoryId,
    required int amount,
    required String note,
    required DateTime date,
  }) async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('transactions ')
        .add({
          'category': categoryId,
          'amount': amount,
          'note': note,
          'date': Timestamp.fromDate(date),
          'created_at': Timestamp.now(),
        });
  }
}
