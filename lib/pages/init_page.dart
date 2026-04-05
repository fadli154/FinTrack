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

    if (!onboardingDone) return "intro";
    if (user != null) return "main";
    return "login";
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
