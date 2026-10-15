import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/shift_information.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:point_of_sales/utils/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  RxBool hidePassword = true.obs;
  RxBool loggingIn = false.obs;
  RxInt loginAttempt = 0.obs;
  Rx<ShiftInformation> shiftInformation = ShiftInformation().obs;

  TextEditingController userIDController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RxBool shiftDisabled = false.obs;
  RxString shift = "A".obs;

  toggleShowPassword() {
    hidePassword.value = !hidePassword.value;
  }

  Future getUserLogin(user, userGroup) async {
    final refs = await SharedPreferences.getInstance();
    await refs.setString("user", user ?? "");
    await refs.setString("userGroup", userGroup ?? "");
  }

  Future login(BuildContext context) async {
    if (loggingIn.value) return;
    final locked = await LoginLockout.remaining();
    if (locked != null) {
      final mins = (locked.inSeconds / 60).ceil();
      return displayToast(context,
          "Too many failed attempts. Try again in $mins minute(s).");
    }
    loggingIn.value = true;
    Map data = {
      "Code": userIDController.text,
      "Password": passwordController.text,
      "Shift": shift.value
    };
    Request request = Request(url: "Login", body: jsonEncode(data));
    await request.post().then((value) async {
      if (value.statusCode == 200) {
        var body = jsonDecode(value.body);
        var res = body["Result"];
        loginAttempt.value = 0;
        await LoginLockout.reset();
        await TokenStore.write(res["Token"] ?? "");
        // harus selesai sebelum pindah layar: HomeController membaca nilai ini
        await getUserLogin(res["User"], res["UserGroup"]);
        displayToast(context, 'Welcome ${res["User"]}');
        await cekDefaultOutlet();
      } else {
        // hanya penolakan kredensial yang dihitung, bukan gangguan jaringan
        if (value.statusCode < 500 && !Request.isUncertain(value)) {
          await LoginLockout.recordFailure();
        }
        displayToast(context, "Login Failed");
      }
      loggingIn.value = false;
    }).catchError((onError) {
      displayToast(context, "Login Failed");
      printError();
      loggingIn.value = false;
    });
  }

  Future getShiftInformation(BuildContext context) async {
    Request request =
        Request(url: "GetShiftInformation/${userIDController.text}");
    await request.get().then((value) async {
      if (value.statusCode == 200) {
        var body = jsonDecode(value.body);
        Map<String, dynamic> res = body["Result"];
        shiftInformation.value = ShiftInformation.fromJson(res);
        if (shiftInformation.value.shift != "") {
          shift.value = shiftInformation.value.shift;
          shiftDisabled.value = true;
          shift.refresh();
        }
      }
    }).catchError((onError) {
      printError();
    });
  }

  cekDefaultOutlet() async {
    final prefs = await SharedPreferences.getInstance();
    String outlet = prefs.getString("defaultOutlet") ?? "";
    if (outlet.isEmpty) {
      Get.offAndToNamed("/setting");
    } else {
      Get.offAndToNamed("/");
    }
  }
}

displayToast(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}
