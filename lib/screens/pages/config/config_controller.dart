import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:point_of_sales/utils/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigController extends GetxController {
  RxString host = "".obs;
  RxString port = "".obs;
  RxBool connecting = false.obs;
  RxBool useHttps = false.obs;

  TextEditingController hostController = TextEditingController();
  TextEditingController portController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadConfig();
  }

  Future saveConfig(context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('host', hostController.text.trim());
    await prefs.setString('port', portController.text.trim());
    await prefs.setBool('useHttps', useHttps.value);
    await prefs.setString('user', "");
    await prefs.setString('userGroup', "");
    await TokenStore.clear();
    await loadConfig();
    testConnection(context);
  }

  Future loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    hostController.text = prefs.getString('host') ?? "";
    portController.text = prefs.getString('port') ?? "";
    useHttps.value = prefs.getBool('useHttps') ?? false;
  }

  Future testConnection(BuildContext context) async {
    if (connecting.value == true) return;
    connecting.value = true;
    try {
      Request request = Request(url: "TestConnection");
      var res = await request.testConnection();
      if (res.statusCode == 200) {
        displayToast(context, "Connection successfully");
        Get.offAndToNamed("/login");
      } else {
        displayToast(context, "Connection failed (${res.statusCode})");
      }
    } catch (_) {
      // SocketException, TimeoutException, dll.
      displayToast(context, "Connection error");
    }
    connecting.value = false;
  }

  displayToast(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  String? portValidator(String value) {
    String pattern = r'^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Invalid port number';
    } else {
      return null;
    }
  }

  String? hostValidator(String value) {
    final host = value.trim();
    if (host.isEmpty || host.length > 253) return 'Invalid hostname';
    // Label DNS (huruf/angka/'-', tidak diawali/diakhiri '-'), dipisah titik.
    final hostname = RegExp(
        r'^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$');
    return hostname.hasMatch(host) ? null : 'Invalid hostname';
  }
}
