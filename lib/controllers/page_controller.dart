import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class PageControllers extends GetxController
    with GetSingleTickerProviderStateMixin {
  var pageIndex = 0.obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
  }

  void changePage(int index) {
    pageIndex.value = index;
    tabController.animateTo(index);
  }
}
