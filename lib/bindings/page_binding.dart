import 'package:get/get.dart';
import 'package:fintrack/controllers/page_controller.dart';

class PageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PageControllers>(() => PageControllers());
  }
}
