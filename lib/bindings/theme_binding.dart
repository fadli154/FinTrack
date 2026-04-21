import 'package:fintrack/controllers/thme_controller.dart';
import 'package:get/get.dart';

class ThemeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThemeController>(() => ThemeController());
  }
}
