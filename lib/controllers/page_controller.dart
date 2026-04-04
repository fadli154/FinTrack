import 'package:get/state_manager.dart';

class PageControllers extends GetxController {
  var pageIndex = 0.obs;

  void changePage(int index) {
    pageIndex.value = index;
  }
}
