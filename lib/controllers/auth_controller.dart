import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> forgotPassword(String email) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        showSnack(
          title: "Error",
          message: "Email tidak terdaftar",
          isError: true,
        );
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);

      showSnack(
        title: "Berhasil",
        message: "Link reset password dikirim ke email",
      );
    } on FirebaseAuthException catch (e) {
      showSnack(
        title: "Error",
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
            'created_at': FieldValue.serverTimestamp(),
          });

      showSnack(title: "Berhasil", message: "Akun berhasil dibuat");

      Get.offAllNamed('/init');
    } on FirebaseAuthException catch (e) {
      showSnack(
        title: "Error",
        message: getErrorMessage(e.code),
        isError: true,
      );
    } catch (e) {
      showSnack(
        title: "Error",
        message: "Gagal simpan data user",
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

      Get.offAllNamed('/init');
    } catch (e) {
      showSnack(
        title: "Error",
        message: "Email atau password salah",
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

      await _auth.signInWithCredential(credential);

      Get.offAllNamed('/init');
    } catch (e) {
      showSnack(title: "Error", message: "Login Google gagal", isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
