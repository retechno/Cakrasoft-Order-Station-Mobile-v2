import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/controllers/special_access_controller.dart';
import 'package:point_of_sales/models/captain_order/captain_order.dart';
import 'package:point_of_sales/models/captain_order/outlet_model.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_screen.dart';
import 'package:point_of_sales/screens/pages/order/orders_page.dart';
import 'package:point_of_sales/utils/mutation_guard.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:point_of_sales/widget/reason_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaptainOrderItemController extends GetxController {
  RxBool loading = false.obs;
  late Map<String, dynamic> body;
  RxList<CaptainOrder> captainOrderItemList = <CaptainOrder>[].obs;
  RxList<Outlet> outletList = <Outlet>[].obs;

  // user access
  SpecialAccessController specialAccessController = SpecialAccessController();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RxBool hidePassword = true.obs;

  int _accessId = 0;
  RxBool isLoadingIndicator = false.obs;
  RxString accessStatus = "".obs;

  RxInt id = 0.obs;
  RxBool isLoading = true.obs;
  RxString categoryCode = "".obs;
  RxString outletCode = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadSetting();
    loadOutletList();
  }

  void toOrderDetailPage() {
    Get.to(() => OrderDetailScreen());
  }

  void toCaptainOrderTransactionPage(int? captainOrderId) {
    id.value = captainOrderId!;
    Get.to(() => CaptainOrderTransactionScreen());
  }

  Future loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    outletCode.value = prefs.getString("defaultOutlet") ?? "";
    loadCaptainOrderList();
  }

//API
  Future saveSpecialAccess(
      BuildContext context, CaptainOrder captainOrder, accessMode) async {
    var res = await specialAccessController.specialAccess(
        userController.text, passwordController.text, accessMode);
    if (!context.mounted) return;
    String message = "You don't have access";
    if (res) {
      showReasonInputDialog(context, captainOrder.idLog!);
    } else {
      accessStatus.value = message;
      accessStatus.refresh();
      Future.delayed(Duration(milliseconds: 2000), () {
        accessStatus.value = "";
        accessStatus.refresh();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  cancelCaptainOrder(int captainOrderId, String reason) =>
      MutationGuard.run('co:$captainOrderId:cancel',
          () => _cancelCaptainOrder(captainOrderId, reason));

  Future _cancelCaptainOrder(int captainOrderId, String reason) async {
    isLoading.value = true;
    captainOrderItemList.clear();
    Map data = {
      "captain_order_id": captainOrderId,
      "cancel_by": userController.text,
      "reason": reason,
    };
    try {
      Request request =
          Request(url: 'CancelCaptainOrder', body: jsonEncode(data));
      var res = await request.put();
      if (res.statusCode != 200 && kDebugMode) {
        print('Backend error');
      }
      // Selalu muat ulang: list sudah dikosongkan di atas, dan hasil
      // pembatalan harus dibaca dari server (bisa saja tidak pasti).
      loadCaptainOrderList();
    } catch (e) {
      loadCaptainOrderList();
    }
    isLoading.value = false;
  }

  loadCaptainOrderList() async {
    isLoading.value = true;
    captainOrderItemList.clear();
    try {
      Request request = Request(url: 'CaptainOrders?code=${outletCode.value}');
      var res = await request.get();
      if (res.statusCode == 200) {
        Map result = jsonDecode(res.body);
        List jsonResponse = result["Result"];
        captainOrderItemList.value =
            jsonResponse.map((e) => CaptainOrder.fromJson(e)).toList();
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      // Get.offAllNamed("/urlSetup");
    }
    isLoading.value = false;
  }

  loadOutletList() async {
    try {
      Request request = Request(url: 'Outlets');
      var res = await request.get();
      if (res.statusCode == 200) {
        Map result = jsonDecode(res.body);
        List jsonResponse = result["Result"];
        outletList.value = jsonResponse.map((e) => Outlet.fromJson(e)).toList();
      } else {
        print('Backend err');
      }
    } catch (e) {
      // Get.offAllNamed("/urlSetup");
    }
  }

  showReasonInputDialog(BuildContext context, int captainOrderId) async {
    String? text = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomInputDialog(
          onSave: (String inputText) {
            // Do something with the input text (save to database, etc.)
            cancelCaptainOrder(captainOrderId, inputText);
            print("Input Text: $inputText");
          },
          onCancel: () {
            // Do something when the user cancels the dialog
            print("Dialog cancelled");
          },
        );
      },
    );

    // The 'text' variable will contain the value entered by the user when saved, or null if cancelled
    if (text != null) {
      print("User entered: $text");
    }
  }
}
