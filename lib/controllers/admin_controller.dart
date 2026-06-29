import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/core/models/app_user.dart';
import 'package:fintrack/core/models/user_role.dart';
import 'package:fintrack/core/models/user_status.dart';
import 'package:fintrack/core/repositories/user_repository.dart';
import 'package:get/get.dart';

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

  // ─── Stats ─────────────────────────────────────────────────────────────
  final RxInt totalUsers = 0.obs;
  final RxInt activeUsers = 0.obs;
  final RxInt disabledUsers = 0.obs;
  final RxInt totalTransactions = 0.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxBool statsLoading = true.obs;

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
    });
  }

  void _listenGlobalCategories() {
    UserRepository.watchGlobalCategories().listen((cats) {
      globalCategories.assignAll(cats);
    });
  }

  Future<void> loadStats() async {
    statsLoading.value = true;
    try {
      // Aggregate transactions across all users
      int txCount = 0;
      double income = 0;
      double expense = 0;

      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();

      // Batch reads (1 subcollection per user — efficient for small-medium user bases)
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
          if (isIncome) {
            income += amount;
          } else {
            expense += amount;
          }
        }
      }

      totalTransactions.value = txCount;
      totalIncome.value = income;
      totalExpense.value = expense;
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

  Future<void> addCategory(String name, String icon) async {
    await UserRepository.addGlobalCategory(name, icon);
  }

  Future<void> deleteCategory(String id) async {
    await UserRepository.deleteGlobalCategory(id);
  }
}
