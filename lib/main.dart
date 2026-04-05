import 'package:fintrack/bindings/auth_binding.dart';
import 'package:fintrack/pages/auth/login_page.dart';
import 'package:fintrack/pages/auth/register_page.dart';
import 'package:fintrack/pages/init_page.dart';
import 'package:fintrack/pages/introduction_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fintrack/bindings/page_binding.dart';
// import 'package:fintrack/pages/main/home.dart';
import 'package:fintrack/pages/main/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 0, 181, 163),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),

        colorScheme: ColorScheme.dark(
          primary: const Color.fromARGB(255, 0, 183, 165),
          secondary: Colors.white,
          surface: const Color.fromARGB(255, 0, 185, 167),
          tertiary: const Color.fromARGB(171, 0, 0, 0),
          inversePrimary: const Color.fromARGB(255, 0, 183, 165),
          inverseSurface: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 53, 53, 53),
        scaffoldBackgroundColor: const Color.fromARGB(255, 44, 44, 44),

        colorScheme: ColorScheme.dark(
          primary: Color.fromARGB(255, 53, 53, 53),
          secondary: Color.fromARGB(255, 70, 70, 70),
          surface: const Color.fromARGB(152, 14, 201, 117),
          tertiary: const Color.fromARGB(208, 255, 255, 255),
          inversePrimary: const Color.fromARGB(255, 226, 226, 226),
          inverseSurface: const Color.fromARGB(186, 255, 255, 255),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 26, 26, 26),
          foregroundColor: const Color.fromARGB(255, 0, 181, 163),
        ),
      ),

      themeMode: ThemeMode.system,

      home: InitPage(),
      getPages: [
        GetPage(
          name: '/init',
          page: () => InitPage(),
          bindings: [AuthBinding()],
        ),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          bindings: [AuthBinding()],
        ),
        GetPage(
          name: '/register',
          page: () => RegisterPage(),
          bindings: [AuthBinding()],
        ),
        GetPage(
          name: '/main',
          page: () => MyMainPage(title: 'FinTrack'),
          bindings: [PageBinding(), AuthBinding()],
        ),
        GetPage(name: '/intro', page: () => IntroductionPage()),
      ],
    );
  }
}
