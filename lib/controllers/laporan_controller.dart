import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum ReportFilter { all, today, month, custom }

class TransactionType {
  static const income = 'pemasukan';
  static const expense = 'pengeluaran';
}

class LaporanController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  final displayedTransactionGroups = <Map<String, dynamic>>[].obs;

  final int pageSize = 5;

  int _currentPage = 1;

  final totalIncome = 0.obs;
  final totalExpense = 0.obs;

  final _averageIncome = 0.0.obs;
  final _averageExpense = 0.0.obs;

  final isLoading = true.obs;

  final selectedFilter = ReportFilter.all.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final categorySummary = <Map<String, dynamic>>[].obs;
  final transactionGroups = <Map<String, dynamic>>[].obs;

  final Map<String, Map<String, dynamic>> categoryMap = {};

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _trxSub;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _transactions = [];
  final List<QueryDocumentSnapshot<Map<String, dynamic>>>
  _filteredTransactions = [];

  double get averageIncome => _averageIncome.value;
  double get averageExpense => _averageExpense.value;

  @override
  void onInit() {
    super.onInit();
    _initController();
  }

  Future<void> _initController() async {
    try {
      isLoading.value = true;

      if (userId == null) {
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
    } finally {
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

  bool _isTransactionIncluded(DateTime transactionDay) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    switch (selectedFilter.value) {
      case ReportFilter.today:
        return DateUtils.isSameDay(transactionDay, today);

      case ReportFilter.month:
        return transactionDay.year == now.year &&
            transactionDay.month == now.month;

      case ReportFilter.custom:
        if (startDate.value == null || endDate.value == null) {
          return false;
        }

        final start = DateUtils.dateOnly(startDate.value!);
        final end = DateUtils.dateOnly(endDate.value!);

        return !transactionDay.isBefore(start) && !transactionDay.isAfter(end);

      case ReportFilter.all:
        return true;
    }
  }

  void _recalculate() {
    int income = 0;
    int expense = 0;

    int incomeCount = 0;
    int expenseCount = 0;

    final summary = <String, Map<String, dynamic>>{};
    final groupedTransactions = <DateTime, List<Map<String, dynamic>>>{};

    _filteredTransactions.clear();

    for (final doc in _transactions) {
      final data = doc.data();

      final transactionDate = _toDate(data['date']);
      if (transactionDate == null) continue;

      final transactionDay = DateUtils.dateOnly(transactionDate);
      if (!_isTransactionIncluded(transactionDay)) continue;

      _filteredTransactions.add(doc);

      final amount = _toInt(data['amount']);
      final categoryId = data['category']?.toString();

      final categoryData = categoryId != null ? categoryMap[categoryId] : null;
      final type =
          (data['type'] ?? categoryData?['type'] ?? TransactionType.expense)
              .toString();

      final categoryName =
          (categoryData?['name'] ?? data['categoryName'] ?? 'Lainnya')
              .toString();

      final key = categoryId ?? categoryName;

      groupedTransactions.putIfAbsent(transactionDay, () => []);
      groupedTransactions[transactionDay]!.add({
        'title': data['title'] ?? categoryName,
        'category': categoryName,
        'amount': amount,
        'type': type,
        'date': transactionDate,
      });

      summary.putIfAbsent(key, () {
        return {'name': categoryName, 'amount': 0, 'type': type};
      });

      summary[key]!['amount'] = (summary[key]!['amount'] as int) + amount;

      if (type == TransactionType.income) {
        income += amount;
        incomeCount++;
      } else {
        expense += amount;
        expenseCount++;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;

    _averageIncome.value = incomeCount == 0 ? 0 : income / incomeCount;
    _averageExpense.value = expenseCount == 0 ? 0 : expense / expenseCount;

    categorySummary.value = summary.values.toList()
      ..sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));

    transactionGroups.value = groupedTransactions.entries.map((e) {
      final transactions = e.value;

      final incomeTotal = transactions
          .where((trx) => trx['type'] == TransactionType.income)
          .fold<int>(0, (total, trx) => total + (trx['amount'] as int));

      final expenseTotal = transactions
          .where((trx) => trx['type'] != TransactionType.income)
          .fold<int>(0, (total, trx) => total + (trx['amount'] as int));

      return {
        'date': DateFormat('EEEE, dd MMM yyyy', 'id').format(e.key),
        'income': incomeTotal,
        'expense': expenseTotal,
        'transactions': transactions,
      };
    }).toList();

    _currentPage = 1;
    _applyPagination();

    isLoading.value = false;
  }

  void changeFilter(ReportFilter filter) {
    selectedFilter.value = filter;

    if (filter != ReportFilter.custom) {
      startDate.value = null;
      endDate.value = null;
    }

    _recalculate();
  }

  void setCustomDate(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    selectedFilter.value = ReportFilter.custom;
    _recalculate();
  }

  int get totalBalance => totalIncome.value - totalExpense.value;

  int get totalTransactionCount => _filteredTransactions.length;

  double get averageTransaction {
    if (_filteredTransactions.isEmpty) return 0;

    int totalAmount = 0;
    for (final trx in _filteredTransactions) {
      final data = trx.data();
      totalAmount += _toInt(data['amount']);
    }

    return totalAmount / _filteredTransactions.length;
  }

  bool get isEmpty =>
      totalIncome.value == 0 &&
      totalExpense.value == 0 &&
      categorySummary.isEmpty;

  String get periodLabel {
    switch (selectedFilter.value) {
      case ReportFilter.today:
        return 'Hari ini';

      case ReportFilter.month:
        return DateFormat('MMMM yyyy', 'id').format(DateTime.now());

      case ReportFilter.custom:
        if (startDate.value != null && endDate.value != null) {
          return '${DateFormat('dd MMM yyyy', 'id').format(startDate.value!)} - ${DateFormat('dd MMM yyyy', 'id').format(endDate.value!)}';
        }
        return 'Custom';

      case ReportFilter.all:
        return 'All Time';
    }
  }

  void _applyPagination() {
    final endIndex = (_currentPage * pageSize);

    if (endIndex >= transactionGroups.length) {
      displayedTransactionGroups.value = transactionGroups;
    } else {
      displayedTransactionGroups.value = transactionGroups.sublist(0, endIndex);
    }
  }

  bool get hasMoreData {
    return displayedTransactionGroups.length < transactionGroups.length;
  }

  void loadMoreTransactions() {
    if (!hasMoreData) return;

    _currentPage++;
    _applyPagination();
  }

  List<Map<String, dynamic>> get sortedCategoryEntries => categorySummary;

  @override
  void onClose() {
    _trxSub?.cancel();
    super.onClose();
  }
}
