import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChartController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final income = 0.0.obs;
  final expense = 0.0.obs;
  final isLoading = true.obs;
  final touchedIndex = (-1).obs;

  final selectedFilter = 'all'.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final Map<String, dynamic> categoryMap = {};

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _trxSub;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _transactions = [];

  @override
  void onInit() {
    super.onInit();
    _initController();
  }

  Future<void> _initController() async {
    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        isLoading.value = false;
        return;
      }

      final categorySnapshot = await firestore.collection('categories').get();
      for (final doc in categorySnapshot.docs) {
        categoryMap[doc.id] = doc.data();
      }

      _trxSub = firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions ')
          .snapshots()
          .listen((snapshot) {
            _transactions = snapshot.docs;
            _recalculate();
          });
    } catch (e) {
      debugPrint('ChartController init error: $e');
      isLoading.value = false;
    }
  }

  DateTime? _toDate(dynamic raw) {
    if (raw == null) return null;

    if (raw is Timestamp) {
      return raw.toDate();
    }

    if (raw is DateTime) {
      return raw;
    }

    if (raw is String) {
      return DateTime.tryParse(raw);
    }

    return null;
  }

  double _toDouble(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? 0.0;
  }

  void _recalculate() {
    double totalIncome = 0;
    double totalExpense = 0;

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    for (final doc in _transactions) {
      final data = doc.data();

      final dateRaw = data['date'];
      final transactionDate = _toDate(dateRaw);
      if (transactionDate == null) continue;

      final transactionDay = DateUtils.dateOnly(transactionDate);

      bool includeData = true;

      switch (selectedFilter.value) {
        case 'today':
          includeData = DateUtils.isSameDay(transactionDay, today);
          break;

        case 'month':
          includeData =
              transactionDay.year == now.year &&
              transactionDay.month == now.month;
          break;

        case 'custom':
          if (startDate.value != null && endDate.value != null) {
            final start = DateUtils.dateOnly(startDate.value!);
            final end = DateUtils.dateOnly(endDate.value!);

            includeData =
                !transactionDay.isBefore(start) && !transactionDay.isAfter(end);
          }
          break;

        case 'all':
        default:
          includeData = true;
      }

      if (!includeData) continue;

      final amount = _toDouble(data['amount']);

      final categoryId = data['category']?.toString();
      final category = categoryId != null ? categoryMap[categoryId] : null;

      final type = (data['type'] ?? category?['type'])?.toString();

      if (type == 'pemasukan') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    }

    income.value = totalIncome;
    expense.value = totalExpense;
    isLoading.value = false;

    debugPrint(
      'Chart recalculated | filter=${selectedFilter.value} | income=$totalIncome | expense=$totalExpense | trx=${_transactions.length}',
    );
  }

  void changeFilter(String value) {
    selectedFilter.value = value;
    _recalculate();
  }

  void setCustomDate(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    selectedFilter.value = 'custom';
    _recalculate();
  }

  @override
  void onClose() {
    _trxSub?.cancel();
    super.onClose();
  }
}
