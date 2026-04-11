import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>>? transaksiStream;
  Stream<QuerySnapshot<Map<String, dynamic>>> getCategories() {
    return FirebaseFirestore.instance.collection('categories').snapshots();
  }

  final RxMap<String, Map<String, dynamic>> categoryMap =
      <String, Map<String, dynamic>>{}.obs;

  void listenCategories() {
    FirebaseFirestore.instance.collection('categories').snapshots().listen((
      snapshot,
    ) {
      final map = <String, Map<String, dynamic>>{};

      for (var doc in snapshot.docs) {
        map[doc.id] = doc.data(); // id = "makanan"
      }

      categoryMap.value = map;
    });
  }

  @override
  void onInit() {
    super.onInit();

    if (user != null) {
      transaksiStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection("transactions ")
          .orderBy("date", descending: true)
          .snapshots();
    }

    listenCategories();
  }

  Future<void> deleteTransaction(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('transactions ')
        .doc(id)
        .delete();
  }

  IconData getIconFromString(String? iconName) {
    final Map<String, IconData> iconMap = {
      'work': Icons.work,
      'fastfood': Icons.fastfood,
      'shopping_cart': Icons.shopping_cart,
      'car': Icons.directions_car,
      'movie': Icons.movie,
      'health': Icons.local_hospital,
      'school': Icons.school,
      'other': Icons.attach_money,
    };

    return iconMap[iconName] ?? Icons.attach_money;
  }

  Color getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.grey;
    }

    final buffer = StringBuffer();
    if (hexColor.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexColor.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String capitalizeEachWord(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Map<String, List<DocumentSnapshot>> groupByDate(List docs) {
    final Map<String, List<DocumentSnapshot>> grouped = {};

    for (var doc in docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();

      final key = DateFormat('yyyy-MM-dd').format(date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(doc); // ✅ simpan doc, bukan data
    }

    return grouped;
  }
}
