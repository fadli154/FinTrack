import 'package:fintrack/controllers/thme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final authC = Get.find<AuthController>();

  final themeController = Get.put(ThemeController());

  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                'assets/particles/Ellipse1.png',
                fit: BoxFit.cover, // Ensures it fills the stack area
                width: 260,
                height: 260,
              ),
            ),
            Positioned(
              top: -40,
              right: -20,
              child: Image.asset(
                'assets/particles/Ellipse2.png',
                width: 400,
                height: 400,
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 110,
                    left: 20,
                    right: 20,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔤 TEXT
                        Container(
                          padding: const EdgeInsets.only(top: 80, bottom: 20),
                          child: Text(
                            "Login here",
                            style: TextStyle(
                              color: colors.surface,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.only(bottom: 80),
                          width: 200,
                          child: Text(
                            textAlign: TextAlign.center,
                            "Welcome back you've been missed!",
                            style: TextStyle(
                              color: colors.tertiary,
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                          ),
                        ),

                        // EMAIL
                        TextField(
                          controller: emailC,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: colors.onSurface),

                          decoration: InputDecoration(
                            labelText: "Email",

                            filled: true,
                            fillColor: colors.surface.withValues(alpha: .35),

                            prefixIcon: Icon(Icons.email),
                            prefixIconColor: const Color.fromARGB(
                              221,
                              255,
                              255,
                              255,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,

                            labelStyle: TextStyle(
                              color: const Color.fromARGB(220, 255, 255, 255),
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(0, 0, 0, 0),
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colors.primary,
                                width: 2,
                              ),
                            ),

                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),

                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // PASSWORD
                        Obx(
                          () => TextField(
                            controller: passC,
                            obscureText: authC.isVisible.value,
                            style: TextStyle(color: colors.onSurface),

                            decoration: InputDecoration(
                              labelText: "Password",

                              filled: true,
                              fillColor: colors.surface.withValues(alpha: .35),

                              suffixIcon: IconButton(
                                onPressed: () {
                                  authC.toggleVisibility();
                                },
                                icon: Icon(
                                  authC.isVisible.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),

                              prefixIcon: Icon(Icons.lock),
                              prefixIconColor: const Color.fromARGB(
                                221,
                                255,
                                255,
                                255,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,

                              labelStyle: TextStyle(
                                color: const Color.fromARGB(220, 255, 255, 255),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 0, 0, 0),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colors.primary,
                                  width: 2,
                                ),
                              ),

                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),

                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 70),

                        // BUTTON
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.surface.withValues(
                                      alpha: 0.7,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.surface,
                                  foregroundColor: colors.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation:
                                      0, // penting biar gak tabrakan sama shadow kita
                                ),
                                onPressed: authC.isLoading.value
                                    ? null
                                    : () {
                                        authC.login(emailC.text, passC.text);
                                      },
                                child: authC.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: colors.secondary,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextButton(
                          onPressed: () {
                            Get.toNamed('/register');
                          },
                          style: ButtonStyle(),
                          child: RichText(
                            text: TextSpan(
                              text: "Belum punya akun? ",
                              style: TextStyle(color: colors.tertiary),
                              children: [
                                TextSpan(
                                  text: "Register",
                                  style: TextStyle(
                                    color: colors.surface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -90,
              left: -200,
              child: Image.asset(
                'assets/particles/Rectangle1.png',
                width: 400,
                height: 400,
              ),
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
      ),
    );
  }
}
