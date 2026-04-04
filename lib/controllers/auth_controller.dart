import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  RxBool isVisible = true.obs;

  void toggleVisibility() => {isVisible.toggle()};

  // 🔥 ERROR MAPPING
  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah (min 6 karakter)';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }

  // 🎨 SNACKBAR CUSTOM
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
        child: const Text("Tutup", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // REGISTER
  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      showSnack(title: "Berhasil", message: "Akun berhasil dibuat");
    } on FirebaseAuthException catch (e) {
      showSnack(
        title: "Error",
        message: getErrorMessage(e.code),
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

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      showSnack(title: "Berhasil", message: "Login sukses");

      Get.offAllNamed('/main');
    } on FirebaseAuthException catch (e) {
      showSnack(
        title: "Login Gagal",
        message: getErrorMessage(e.code),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();

    showSnack(title: "Logout", message: "Berhasil keluar");

    Get.offAllNamed('/login');
  }
}
