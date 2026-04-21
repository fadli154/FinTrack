import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  var isDark = false.obs;

  @override
  void onInit() {
    super.onInit();

    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    isDark.value = brightness == Brightness.dark;
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }
}
