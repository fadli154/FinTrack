import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/core/models/app_mode.dart';
import 'package:fintrack/core/models/app_user.dart';
import 'package:fintrack/core/repositories/user_repository.dart';
import 'package:fintrack/core/services/permission_service.dart';
import 'package:get/get.dart';

/// Permanent singleton. Holds the currently logged-in AppUser.
/// Any controller/widget can call `Get.find<UserController>()` to check role.
class UserController extends GetxController {
  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);

  bool get isAdmin => PermissionService.isAdmin(currentUser.value);
  bool get isLoggedIn => currentUser.value != null;
  AppMode get currentAppMode => currentUser.value?.appMode ?? AppMode.user;
  bool get isInAdminMode => isAdmin && currentAppMode.isAdmin;

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToUser(user.uid);
      } else {
        currentUser.value = null;
      }
    });
  }

  void _listenToUser(String uid) {
    UserRepository.watchUser(uid).listen((appUser) {
      currentUser.value = appUser;
    });
  }

  /// Force-refresh the current user (e.g. after role change by admin).
  Future<void> refreshUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    currentUser.value = await UserRepository.getUser(uid);
  }

  /// Switch between Admin Mode and User Mode.
  /// Persists to Firestore, then navigates to the correct shell.
  Future<void> switchAppMode(AppMode newMode) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await UserRepository.setAppMode(uid, newMode);
    // Stream will update currentUser automatically.
    // Navigate to the correct shell after a brief delay for the stream to settle.
    await Future.delayed(const Duration(milliseconds: 200));
    if (newMode.isAdmin) {
      Get.offAllNamed('/admin');
    } else {
      Get.offAllNamed('/main');
    }
  }
}
