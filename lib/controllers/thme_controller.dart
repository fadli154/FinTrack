import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final box = GetStorage();
  var isDark = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 🔥 ambil dari storage dulu
    final savedTheme = box.read('isDark');

    if (savedTheme != null) {
      isDark.value = savedTheme;
    } else {
      // fallback ke system
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDark.value = brightness == Brightness.dark;
    }

    // apply theme
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    isDark.value = !isDark.value;

    // 🔥 simpan ke local
    box.write('isDark', isDark.value);

    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }
}
