import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  Future<String> checkFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    final user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 1));

    if (!onboardingDone) return "intro";
    if (user != null) return "main";
    return "login";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: checkFlow(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        Future.microtask(() {
          if (snapshot.data == "intro") {
            Get.offAllNamed('/intro');
          } else if (snapshot.data == "main") {
            Get.offAllNamed('/main');
          } else {
            Get.offAllNamed('/login');
          }
        });

        return const SizedBox();
      },
    );
  }
}
