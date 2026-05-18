import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LaporanController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  final totalIncome = 0.obs;
  final totalExpense = 0.obs;
  final isLoading = true.obs;

  final selectedFilter = 'all'.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final categorySummary = <Map<String, dynamic>>[].obs;

  final Map<String, Map<String, dynamic>> categoryMap = {};

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

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      await _loadCategories();

      _trxSub = firestore
          .collection('users')
          .doc(userId)
          .collection('transactions ')
          .snapshots()
          .listen(
            (snapshot) {
              _transactions = snapshot.docs;
              _recalculate();
            },
            onError: (e) {
              debugPrint('LaporanController trx error: $e');
              isLoading.value = false;
            },
          );
    } catch (e) {
      debugPrint('LaporanController init error: $e');
      isLoading.value = false;
    }
  }

  Future<void> _loadCategories() async {
    final categorySnapshot = await firestore.collection('categories').get();
    categoryMap.clear();

    for (final doc in categorySnapshot.docs) {
      categoryMap[doc.id] = doc.data();
    }
  }

  DateTime? _toDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  int _toInt(dynamic raw) {
    if (raw == null) return 0;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString()) ?? 0;
  }

  void _recalculate() {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    int income = 0;
    int expense = 0;

    final summary = <String, Map<String, dynamic>>{};

    for (final doc in _transactions) {
      final data = doc.data();

      final transactionDate = _toDate(data['date']);
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
          } else {
            includeData = false;
          }
          break;

        case 'all':
        default:
          includeData = true;
      }

      if (!includeData) continue;

      final amount = _toInt(data['amount']);
      final categoryId = data['category']?.toString();

      final categoryData = categoryId != null ? categoryMap[categoryId] : null;
      final type = (data['type'] ?? categoryData?['type'] ?? 'pengeluaran')
          .toString();
      final categoryName =
          (categoryData?['name'] ?? data['categoryName'] ?? 'Lainnya')
              .toString();

      final key = categoryId ?? categoryName;

      summary.putIfAbsent(key, () {
        return {'name': categoryName, 'amount': 0, 'type': type};
      });

      summary[key]!['amount'] = (summary[key]!['amount'] as int) + amount;

      if (type == 'pemasukan') {
        income += amount;
      } else {
        expense += amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    categorySummary.value = summary.values.toList()
      ..sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));

    isLoading.value = false;
  }

  void changeFilter(String value) {
    selectedFilter.value = value;

    if (value != 'custom') {
      startDate.value = null;
      endDate.value = null;
    }

    _recalculate();
  }

  void setCustomDate(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    selectedFilter.value = 'custom';
    _recalculate();
  }

  int get totalBalance => totalIncome.value - totalExpense.value;

  bool get isEmpty =>
      totalIncome.value == 0 &&
      totalExpense.value == 0 &&
      categorySummary.isEmpty;

  String get periodLabel {
    switch (selectedFilter.value) {
      case 'today':
        return 'Hari ini';
      case 'month':
        return DateFormat('MMMM yyyy', 'id').format(DateTime.now());
      case 'custom':
        if (startDate.value != null && endDate.value != null) {
          return '${DateFormat('dd MMM yyyy', 'id').format(startDate.value!)} - ${DateFormat('dd MMM yyyy', 'id').format(endDate.value!)}';
        }
        return 'Custom';
      default:
        return 'All time';
    }
  }

  List<Map<String, dynamic>> get sortedCategoryEntries => categorySummary;

  @override
  void onClose() {
    _trxSub?.cancel();
    super.onClose();
  }
}
