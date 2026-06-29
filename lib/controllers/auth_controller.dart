import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fintrack/core/models/user_role.dart';
import 'package:fintrack/core/models/user_status.dart';
import 'package:fintrack/core/services/auth_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  var isLoading = false.obs;
  RxBool isVisible = true.obs;

  void toggleVisibility() => {isVisible.toggle()};

  // 🔥 ERROR MAPPING
  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'error_user_not_found'.tr;
      case 'wrong-password':
        return 'error_wrong_password'.tr;
      case 'invalid-email':
        return 'error_invalid_email'.tr;
      case 'email-already-in-use':
        return 'error_email_already_in_use'.tr;
      case 'weak-password':
        return 'error_weak_password'.tr;
      default:
        return 'error_default'.tr;
    }
  }

  void showSnack({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      backgroundColor: isError ? Colors.red.shade400 : Colors.teal,
      colorText: Colors.white,
      icon: Icon(
        isError ? Icons.error : Icons.check_circle,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: Text("close".tr, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> forgotPassword(String email) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        showSnack(
          title: "error".tr,
          message: "error_user_not_found".tr,
          isError: true,
        );
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);

      showSnack(
        title: "success".tr,
        message: "password_reset_sent".tr,
      );
    } on FirebaseAuthException catch (e) {
      showSnack(
        title: "error".tr,
        message: getErrorMessage(e.code),
        isError: true,
      );
    }
  }

  // REGISTER
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(name);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': name,
            'email': email,
            'role': UserRole.user.toJson(),
            'status': UserStatus.active.toJson(),
            'language': 'en',
            'currency': 'IDR',
            'photo_url': null,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
            'last_login': FieldValue.serverTimestamp(),
          });

      showSnack(title: "success".tr, message: "account_created".tr);

      Get.offAllNamed('/init');
    } on FirebaseAuthException catch (e) {
      showSnack(
        title: "error".tr,
        message: getErrorMessage(e.code),
        isError: true,
      );
    } catch (e) {
      showSnack(
        title: "error".tr,
        message: "save_user_failed".tr,
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // LOGIN
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final appUser = await AuthService.postLogin(credential.user!);

      showSnack(title: "success".tr, message: "login_success".tr);

      if (appUser.isAdmin) {
        Get.offAllNamed('/admin');
      } else {
        Get.offAllNamed('/main');
      }
    } catch (e) {
      showSnack(
        title: "error".tr,
        message: "login_failed".tr,
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();

    showSnack(title: "drawer_logout".tr, message: "logout_success".tr);

    Get.offAllNamed('/login');
  }

  Future<void> initGoogleSignIn() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize();

    _googleSignIn.authenticationEvents
        .listen((event) {
          // optional: tangani event sign-in / sign-out di sini
        })
        .onError((error) {
          // optional: tangani error event di sini
        });

    await _googleSignIn.attemptLightweightAuthentication();
    _googleInitialized = true;
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      await initGoogleSignIn();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception('Platform ini tidak mendukung authenticate().');
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      final appUser = await AuthService.postLogin(result.user!);

      if (appUser.isAdmin) {
        Get.offAllNamed('/admin');
      } else {
        Get.offAllNamed('/main');
      }
    } catch (e) {
      showSnack(title: "error".tr, message: "google_login_failed".tr, isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
