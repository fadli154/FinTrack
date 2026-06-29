import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService {
  static const fallbackLocale = Locale('en', 'US');

  static final locales = [
    const Locale('en', 'US'),
    const Locale('id', 'ID'),
  ];

  static Locale get currentLocale {
    final box = GetStorage();
    final langCode = box.read('langCode') ?? 'en';
    final countryCode = box.read('countryCode') ?? 'US';
    return Locale(langCode, countryCode);
  }

  static String get currentLanguageName {
    final locale = currentLocale;
    if (locale.languageCode == 'id') {
      return 'Bahasa Indonesia';
    }
    return 'English';
  }

  static void changeLocale(String langCode) {
    Locale locale;
    final box = GetStorage();
    if (langCode == 'id') {
      locale = const Locale('id', 'ID');
      box.write('langCode', 'id');
      box.write('countryCode', 'ID');
    } else {
      locale = const Locale('en', 'US');
      box.write('langCode', 'en');
      box.write('countryCode', 'US');
    }
    Get.updateLocale(locale);
  }
}
