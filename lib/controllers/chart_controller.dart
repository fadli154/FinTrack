import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChartController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final income = 0.0.obs;
  final expense = 0.0.obs;
  final isLoading = true.obs;
  final touchedIndex = (-1).obs;

  final selectedFilter = 'all'.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final monthlyLabels = <String>[].obs;
  final monthlyIncomeValues = <double>[].obs;
  final monthlyExpenseValues = <double>[].obs;
  final topExpenseCategories = <Map<String, dynamic>>[].obs;

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

  DateTime _monthKey(DateTime date) => DateTime(date.year, date.month, 1);

  DateTime _nextMonth(DateTime date) => DateTime(date.year, date.month + 1, 1);

  void _recalculate() {
    double totalIncome = 0;
    double totalExpense = 0;

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    final monthlyBuckets = <DateTime, Map<String, double>>{};
    final categoryExpenseMap = <String, double>{};
    DateTime? minMonth;
    DateTime? maxMonth;

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

      final monthKey = _monthKey(transactionDay);
      monthlyBuckets.putIfAbsent(
        monthKey,
        () => {'income': 0.0, 'expense': 0.0},
      );

      if (type == 'pemasukan') {
        totalIncome += amount;

        monthlyBuckets[monthKey]!['income'] =
            (monthlyBuckets[monthKey]!['income'] ?? 0) + amount;
      } else {
        totalExpense += amount;

        monthlyBuckets[monthKey]!['expense'] =
            (monthlyBuckets[monthKey]!['expense'] ?? 0) + amount;

        final categoryName = category?['name']?.toString() ?? 'Lainnya';

        categoryExpenseMap[categoryName] =
            (categoryExpenseMap[categoryName] ?? 0) + amount;
      }

      minMonth = minMonth == null || monthKey.isBefore(minMonth)
          ? monthKey
          : minMonth;
      maxMonth = maxMonth == null || monthKey.isAfter(maxMonth)
          ? monthKey
          : maxMonth;
    }

    income.value = totalIncome;
    expense.value = totalExpense;

    final sortedCategories = categoryExpenseMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topExpenseCategories.value = sortedCategories
        .take(5)
        .map((e) => {'name': e.key, 'amount': e.value})
        .toList();

    monthlyLabels.clear();
    monthlyIncomeValues.clear();
    monthlyExpenseValues.clear();

    if (monthlyBuckets.isNotEmpty && minMonth != null && maxMonth != null) {
      final months = <DateTime>[];
      var cursor = DateTime(minMonth.year, minMonth.month, 1);
      final last = DateTime(maxMonth.year, maxMonth.month, 1);

      while (!cursor.isAfter(last)) {
        months.add(cursor);
        cursor = _nextMonth(cursor);
      }

      for (final month in months) {
        monthlyLabels.add(DateFormat('MMM yy', 'id').format(month));
        monthlyIncomeValues.add(monthlyBuckets[month]?['income'] ?? 0.0);
        monthlyExpenseValues.add(monthlyBuckets[month]?['expense'] ?? 0.0);
      }
    }

    isLoading.value = false;

    debugPrint(
      'Chart recalculated | filter=${selectedFilter.value} | income=$totalIncome | expense=$totalExpense | trx=${_transactions.length}',
    );
  }

  void changeFilter(String value) {
    selectedFilter.value = value;
    touchedIndex.value = -1;
    _recalculate();
  }

  String get periodLabel {
    switch (selectedFilter.value) {
      case 'today':
        return 'Hari Ini';

      case 'month':
        return DateFormat('MMMM yyyy', 'id').format(DateTime.now());

      case 'custom':
        if (startDate.value != null && endDate.value != null) {
          return '${DateFormat('dd MMM yyyy', 'id').format(startDate.value!)} - '
              '${DateFormat('dd MMM yyyy', 'id').format(endDate.value!)}';
        }
        return 'Custom';

      case 'all':
      default:
        return 'All time';
    }
  }

  double get savingRate {
    if (income.value <= 0) return 0;
    return ((income.value - expense.value) / income.value) * 100;
  }

  double get expenseRatio {
    if (income.value <= 0) return 0;
    return (expense.value / income.value) * 100;
  }

  double get netCashflow => income.value - expense.value;

  double get incomeExpenseRatio {
    if (expense.value <= 0) return 0;
    return (income.value / expense.value) * 100;
  }

  double get balancePercentage {
    if (income.value <= 0) return 0;
    return (netCashflow / income.value) * 100;
  }

  double get financialHealthScore {
    if (income.value <= 0) return 0;

    double score = 100;

    if (expenseRatio > 80) {
      score -= 40;
    } else if (expenseRatio > 60) {
      score -= 20;
    }

    if (savingRate > 30) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  String get healthStatus {
    final score = financialHealthScore;

    if (score >= 80) return "Sangat Sehat 🟢";
    if (score >= 60) return "Cukup Sehat 🟡";
    if (score >= 40) return "Perlu Perhatian 🟠";
    return "Bahaya 🔴";
  }

  String get financialInsight {
    if (savingRate >= 50) {
      return "Keuangan kamu sangat sehat 🔥";
    }

    if (savingRate >= 30) {
      return "Bagus, pertahankan tabunganmu 👍";
    }

    if (savingRate >= 10) {
      return "Pengeluaran mulai besar ⚠️";
    }

    return "Pengeluaran lebih besar dari pemasukan 🚨";
  }

  double get trendMaxY {
    final values = <double>[...monthlyIncomeValues, ...monthlyExpenseValues];
    if (values.isEmpty) return 1;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    return maxValue <= 0 ? 1 : maxValue * 1.25;
  }

  void setCustomDate(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    selectedFilter.value = 'custom';
    touchedIndex.value = -1;
    _recalculate();
  }

  @override
  void onClose() {
    _trxSub?.cancel();
    super.onClose();
  }
}
