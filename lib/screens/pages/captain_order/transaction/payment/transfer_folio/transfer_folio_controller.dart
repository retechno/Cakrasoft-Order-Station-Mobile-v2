import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/folio.dart';
import 'package:point_of_sales/models/payment_data.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/cash/cash_payment_screen.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/payment_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:point_of_sales/widget/alert_widget.dart';

class TransferToFolioController extends GetxController {
  PaymentController paymentController = Get.find<PaymentController>();
  RxBool loading = false.obs;
  late Map<String, dynamic> body;
  RxList<Folio> folioList = <Folio>[].obs;
  List folioTypes = [
    {"code": "1", "name": "Guest Folio"},
    {"code": "2", "name": "Master Folio"},
    {"code": "3", "name": "Desk Folio"},
  ];

  RxInt id = 0.obs;
  RxBool isLoading = true.obs;
  RxBool folioIsLock = true.obs;
  RxString folioType = "1".obs;

  @override
  void onInit() {
    super.onInit();
    loadFolioList();
  }

  loadFolioList() async {
    isLoading.value = true;
    folioList.clear();
    try {
      Request request =
          Request(url: 'GetTransferToFolioList?Type=${folioType.value}');
      var res = await request.get();
      if (res.statusCode == 200) {
        Map result = jsonDecode(res.body);
        List jsonResponse = result["Result"];
        folioList.value = jsonResponse.map((e) => Folio.fromJson(e)).toList();
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

  Future getFolioStatus(context, folioNumber) async {
    folioIsLock.value = true;
    try {
      Request request = Request(url: 'GetFolioLockStatus/$folioNumber');
      var res = await request.get();
      if (res.statusCode == 200) {
        Map result = jsonDecode(res.body);
        folioIsLock.value = result["Result"];
        if (folioIsLock.value) {
          showAlert(context, "Folio is Lock, Please unlock it first");
        }
      } else {
        Map result = jsonDecode(res.body);
        int statusCode = result["StatusCode"];
        String message = result["Message"];
        if (statusCode == 999) {
          showAlert(context, message);
        }

        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      // Get.offAllNamed("/urlSetup");
    }
  }

  Future processInputPayment(context, Folio folio) async {
    await getFolioStatus(context, folio.number);
    if (folioIsLock.value) return;

    Get.off(() => CashPaymentScreen(
          paymentData: PaymentData(
              captainOrderId: paymentController.captainOrderId.value,
              accountCode: paymentController.accountCode.value,
              accountName: paymentController.accountName.value,
              folioTransfer: folio.number,
              subFolioTransfer: "A",
              paymentAmount: 0),
        ));
  }

  void showAlert(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertWidget(
          title: "Information",
          content: text,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Dismiss the dialog, return true
              },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Styles.primaryColor),
              ),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
