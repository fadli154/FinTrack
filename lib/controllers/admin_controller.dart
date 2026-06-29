import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/core/models/app_user.dart';
import 'package:fintrack/core/models/user_role.dart';
import 'package:fintrack/core/models/user_status.dart';
import 'package:fintrack/core/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminController extends GetxController {
  // ─── Users ─────────────────────────────────────────────────────────────
  final RxList<AppUser> users = <AppUser>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool usersLoading = true.obs;

  List<AppUser> get filteredUsers {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) return users;
    return users
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q),
        )
        .toList();
  }

  // ─── Summary Stats ──────────────────────────────────────────────────────
  final RxInt totalUsers = 0.obs;
  final RxInt activeUsers = 0.obs;
  final RxInt disabledUsers = 0.obs;
  final RxInt totalTransactions = 0.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxBool statsLoading = true.obs;

  // ─── Chart Data ─────────────────────────────────────────────────────────

  /// User registrations per month — last 6 months.
  /// Key: 'MMM yy' (e.g. 'Jun 25'), Value: count of new users
  final RxMap<String, int> userGrowthData = <String, int>{}.obs;

  /// Monthly income & expense — last 6 months.
  /// Each entry: {'month': 'Jun 25', 'income': 500000.0, 'expense': 300000.0}
  final RxList<Map<String, dynamic>> monthlyTxData =
      <Map<String, dynamic>>[].obs;

  /// Category totals — category name → total amount spent/earned
  final RxMap<String, double> categoryTotals = <String, double>{}.obs;

  // ─── Global Categories ─────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> globalCategories =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenUsers();
    _listenGlobalCategories();
    loadStats();
  }

  void _listenUsers() {
    UserRepository.getAllUsers().listen((list) {
      users.assignAll(list);
      totalUsers.value = list.length;
      activeUsers.value = list.where((u) => u.isActive).length;
      disabledUsers.value = list.where((u) => u.isDisabled).length;
      usersLoading.value = false;
      _computeUserGrowth(list);
    });
  }

  void _listenGlobalCategories() {
    UserRepository.watchGlobalCategories().listen((cats) {
      globalCategories.assignAll(cats);
    });
  }

  /// Build user growth map from the users list (no extra Firestore calls).
  void _computeUserGrowth(List<AppUser> list) {
    final now = DateTime.now();
    final growth = <String, int>{};

    // Initialize last 6 months with 0
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      growth[DateFormat('MMM yy').format(month)] = 0;
    }

    for (final user in list) {
      final date = user.createdAt;
      if (date == null) continue;
      final key = DateFormat('MMM yy').format(date);
      if (growth.containsKey(key)) {
        growth[key] = (growth[key] ?? 0) + 1;
      }
    }

    userGrowthData.assignAll(growth);
  }

  Future<void> loadStats() async {
    statsLoading.value = true;
    try {
      int txCount = 0;
      double income = 0;
      double expense = 0;

      final now = DateTime.now();

      // Initialize last 6 months buckets
      final monthlyMap = <String, Map<String, double>>{};
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i);
        monthlyMap[DateFormat('MMM yy').format(month)] = {
          'income': 0,
          'expense': 0,
        };
      }

      final catTotals = <String, double>{};

      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();

      for (final userDoc in usersSnap.docs) {
        final txSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .collection('transactions')
            .get();

        txCount += txSnap.docs.length;

        for (final tx in txSnap.docs) {
          final data = tx.data();
          final amount = (data['amount'] as num?)?.toDouble() ?? 0;
          final isIncome = data['isIncome'] as bool? ?? false;

          // Summary totals
          if (isIncome) {
            income += amount;
          } else {
            expense += amount;
          }

          // Monthly breakdown
          final rawDate = data['date'] ?? data['created_at'];
          if (rawDate is Timestamp) {
            final month = DateFormat('MMM yy').format(rawDate.toDate());
            if (monthlyMap.containsKey(month)) {
              if (isIncome) {
                monthlyMap[month]!['income'] =
                    (monthlyMap[month]!['income'] ?? 0) + amount;
              } else {
                monthlyMap[month]!['expense'] =
                    (monthlyMap[month]!['expense'] ?? 0) + amount;
              }
            }
          }

          // Category breakdown
          final catId = data['category'] as String?;
          if (catId != null) {
            catTotals[catId] = (catTotals[catId] ?? 0) + amount;
          }
        }
      }

      totalTransactions.value = txCount;
      totalIncome.value = income;
      totalExpense.value = expense;

      // Convert monthly map to ordered list
      monthlyTxData.assignAll(
        monthlyMap.entries
            .map((e) => {
                  'month': e.key,
                  'income': e.value['income'] ?? 0.0,
                  'expense': e.value['expense'] ?? 0.0,
                })
            .toList(),
      );

      // Map category IDs to names using globalCategories
      final resolvedCats = <String, double>{};
      for (final entry in catTotals.entries) {
        final cat = globalCategories.firstWhereOrNull(
          (c) => c['id'] == entry.key,
        );
        final label = cat?['name'] as String? ?? entry.key;
        resolvedCats[label] = (resolvedCats[label] ?? 0) + entry.value;
      }

      // Keep top 6 categories
      final sorted = resolvedCats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      categoryTotals.assignAll(
        Map.fromEntries(sorted.take(6)),
      );
    } catch (_) {
      // Keep previous values on error
    } finally {
      statsLoading.value = false;
    }
  }

  // ─── User Actions ───────────────────────────────────────────────────────

  Future<void> promoteToAdmin(String uid) async {
    await UserRepository.setRole(uid, UserRole.admin);
  }

  Future<void> demoteToUser(String uid) async {
    await UserRepository.setRole(uid, UserRole.user);
  }

  Future<void> disableUser(String uid) async {
    await UserRepository.setStatus(uid, UserStatus.disabled);
  }

  Future<void> enableUser(String uid) async {
    await UserRepository.setStatus(uid, UserStatus.active);
  }

  Future<void> deleteUser(String uid) async {
    await UserRepository.deleteUser(uid);
  }

  // ─── Category Actions ───────────────────────────────────────────────────

  Future<void> addCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
  }) async {
    await UserRepository.addGlobalCategory(
      name: name,
      type: type,
      icon: icon,
      color: color,
    );
  }

  Future<void> deleteCategory(String id) async {
    await UserRepository.deleteGlobalCategory(id);
  }
}
