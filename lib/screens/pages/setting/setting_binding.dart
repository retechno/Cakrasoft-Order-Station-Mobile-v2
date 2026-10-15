import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/setting/setting_controller.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingController>(() => SettingController());
  }
}
