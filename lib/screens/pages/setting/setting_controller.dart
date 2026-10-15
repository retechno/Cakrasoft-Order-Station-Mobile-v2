import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/captain_order/outlet_model.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingController extends GetxController {
  TextEditingController userIDController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RxList<Outlet> outletList = <Outlet>[].obs;
  RxString outletCode = "".obs;

  @override
  void onReady() {
    super.onReady();
    loadOutletList();
  }

  loadOutletList() async {
    try {
      Request request = Request(url: 'Outlets');
      var res = await request.get();
      if (res.statusCode == 200) {
        Map result = jsonDecode(res.body);
        List jsonResponse = result["Result"];
        outletList.value = jsonResponse.map((e) => Outlet.fromJson(e)).toList();
        outletCode.value = outletList.length > 0 ? outletList[0].code : "";
      } else {
        print('Backend err');
      }
    } catch (e) {
      // Get.offAllNamed("/urlSetup");
    }
  }

  // Future defaultConfig() async {
  //   Map<String, Object> host = <String, Object>{'host': ""};
  // }
  Future saveSetting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultOutlet', outletCode.value);

    Get.offAndToNamed("/");
  }
}

displayToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}
