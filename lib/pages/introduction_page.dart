import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  // Reusable Page Decoration
  PageDecoration get _pageDecoration => const PageDecoration(
    imagePadding: EdgeInsets.only(top: 40),
    titleTextStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    bodyTextStyle: TextStyle(fontSize: 18, color: Colors.grey),
    titlePadding: EdgeInsets.only(bottom: 10, top: 40),
    bodyPadding: EdgeInsets.symmetric(horizontal: 12),
    pageMargin: EdgeInsets.only(top: 20),
  );

  // Reusable Page Builder
  PageViewModel _buildPage({
    required String title,
    required String body,
    required String lottie,
  }) {
    return PageViewModel(
      decoration: _pageDecoration,

      titleWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: const EdgeInsets.only(top: 40),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      bodyWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),

      image: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(child: Lottie.asset(lottie, height: 500, width: 500)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,

      pages: [
        _buildPage(
          title: "Track Your Money",
          body:
              "Easily manage your income and expenses, and take full control of your financial life.",
          lottie: 'assets/lotties/MoneyInvestment.json',
        ),
        _buildPage(
          title: "Smart Financial Insights",
          body:
              "Discover where your money goes and improve your habits with smart insights.",
          lottie: 'assets/lotties/Revenue.json',
        ),
      ],

      // Navigation Buttons
      showSkipButton: true,
      skip: const Text("Skip", style: TextStyle(color: Colors.black)),
      next: const Icon(Icons.arrow_forward, color: Colors.greenAccent),
      done: const Text("Start", style: TextStyle(fontWeight: FontWeight.bold)),

      onDone: () {
        Get.offNamed('/login');
      },

      onSkip: () {
        Get.offNamed('/login');
      },

      // Indicator (dots)
      dotsDecorator: DotsDecorator(
        size: const Size(8, 8),
        activeSize: const Size(20, 8),
        activeColor: Theme.of(context).colorScheme.inversePrimary,
        color: Colors.grey.shade300,
        spacing: const EdgeInsets.symmetric(horizontal: 4),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      curve: Curves.easeInOut,
    );
  }
}
