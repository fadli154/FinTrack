import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      // Match user page Scaffold background
      backgroundColor: colors.secondary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container matching category icon style
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 44,
                  color: colors.surface,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'unauthorized_title'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  // heading: colors.tertiary
                  color: colors.tertiary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'unauthorized_body'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.tertiary.withValues(alpha: .6),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Get.offAllNamed('/main'),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  label: Text('back'.tr),
                  style: FilledButton.styleFrom(
                    // Primary button: colors.surface (teal) — matches user app
                    backgroundColor: colors.surface,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
