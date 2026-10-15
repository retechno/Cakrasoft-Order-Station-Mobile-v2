import 'dart:io';

import 'package:get/get.dart';
import 'package:point_of_sales/utils/request.dart';

class SplashScreenController extends GetxController {
  RxBool imageVisible = false.obs;
  @override
  void onInit() {
    super.onInit();
    // testConnection();
    Future.delayed(const Duration(milliseconds: 100)).then((value) => imageVisible.value = true);
    Future.delayed(const Duration(seconds: 3)).then((value) => testConnection());
  }

  Future testConnection() async {
    try {
      Request request = Request(url: "TestConnection");
      var res = await request.testConnection();
      if (res.statusCode == 200) {
        Get.offAndToNamed("/login");
      } else {
        Get.offAndToNamed("/urlSetup");
      }
    } on SocketException {
      Get.offAndToNamed("/urlSetup");
    } catch (error) {
      Get.offAndToNamed("/urlSetup");
    }
  }
}
