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
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ),

      bodyWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),

      image: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(child: Lottie.asset(lottie, height: 300, width: 300)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔥 BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEEF2FF), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Positioned(
            top: -10,
            right: -20,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  'assets/particles/Ellipse3.png',
                  width: 260,
                  height: 260,
                ),
              ),
            ),
          ),

          Positioned(
            top: -40,
            right: -20,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/particles/Ellipse4.png',
                  width: 400,
                  height: 400,
                ),
              ),
            ),
          ),

          IntroductionScreen(
            globalBackgroundColor: Colors.transparent,

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

            showSkipButton: true,
            skip: const Text("Skip", style: TextStyle(color: Colors.black)),

            next: const Icon(Icons.arrow_forward, color: Colors.black),

            done: const Text(
              "Start",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            onDone: () {
              Get.offNamed('/login');
            },

            onSkip: () {
              Get.offNamed('/login');
            },

            dotsDecorator: DotsDecorator(
              size: const Size(8, 8),
              activeSize: const Size(20, 8),
              activeColor: Colors.black,
              color: Colors.grey.shade300,
              spacing: const EdgeInsets.symmetric(horizontal: 4),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            curve: Curves.easeInOut,
          ),
          Positioned(
            bottom: -90,
            left: -200,

            child: Transform.rotate(
              angle: 230,
              child: Image.asset(
                'assets/particles/Rectangle1.png',
                width: 400,
                height: 400,
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -100,

            child: Transform.rotate(
              angle: 200,
              child: Image.asset(
                'assets/particles/Rectangle1.png',
                width: 400,
                height: 400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
