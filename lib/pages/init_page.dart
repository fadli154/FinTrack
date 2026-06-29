import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintrack/core/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  Future<String> checkFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    await FirebaseAuth.instance.authStateChanges().first;

    final user = FirebaseAuth.instance.currentUser;

    if (!onboardingDone) return 'intro';
    if (user == null) return 'login';

    // Check role to decide which shell to show
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        final role = UserRole.fromString(data['role'] as String?);
        if (role.isAdmin) return 'admin';
      }
    } catch (_) {
      // Firestore error — fall back to normal user shell
    }

    return 'main';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: checkFlow(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (snapshot.data) {
            case 'intro':
              Get.offAllNamed('/intro');
            case 'admin':
              Get.offAllNamed('/admin');
            case 'main':
              Get.offAllNamed('/main');
            default:
              Get.offAllNamed('/login');
          }
        });

        return const SizedBox();
      },
    );
  }
}
