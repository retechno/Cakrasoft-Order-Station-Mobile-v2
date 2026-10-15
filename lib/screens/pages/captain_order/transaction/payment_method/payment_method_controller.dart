import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/payment.dart';
import 'package:point_of_sales/models/payment_method.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:point_of_sales/utils/toast.dart';

class PaymentMethodController extends GetxController {
  RxList<PaymentMethod> paymentMethodList = <PaymentMethod>[].obs;
  CaptainOrderTransactionController captainOrderTransactionController =
      Get.put(CaptainOrderTransactionController());
  RxList<Payment> paymentList =
      Get.find<CaptainOrderTransactionController>().paymentList;

  RxInt coNumber = Get.find<CaptainOrderTransactionController>().id;
  RxBool canPayment = false.obs;
  RxBool isLoading = false.obs;

  totalPayment() {
    num total = 0;
    for (var payment in paymentList) {
      total += payment.amount!;
    }
    return total;
  }

  addPayment(accountCode, amount) {
    var index = paymentList
        .indexWhere((itemToCheck) => itemToCheck.accountCode == accountCode);
    if (index >= 0) {
      paymentList[index].amount = int.parse(amount);
    } else {
      paymentList
          .add(Payment(accountCode: accountCode, amount: int.parse(amount)));
    }
    paymentList.refresh();
  }

  getDisplayAmount(PaymentMethod paymentMethod) {
    num amount = 0;
    for (var i = 0; i < paymentList.length; i++) {
      if (paymentMethod.accountCode == paymentList[i].accountCode) {
        amount += paymentList[i].amount ?? 0;
      }
    }

    if (amount <= 0) return const Text("");

    return Text(Formats.formatNumber(amount.toString()));
  }

  Future loadPaymentMethod(context, outletCode) async {
    isLoading.value = true;
    try {
      Request request = Request(url: 'PaymentMethods/$outletCode');
      var value = await request.get();
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        List jsonResponse = result["Result"];
        paymentMethodList.clear();
        paymentMethodList.value =
            jsonResponse.map((e) => PaymentMethod.fromJson(e)).toList();
      } else {
        Map result = jsonDecode(value.body);
        String message = (result["Message"] ?? "").toString();
        int statusCode = result["StatusCode"] is int ? result["StatusCode"] : 0;
        if (statusCode == 999 && message.isNotEmpty) {
          ToastManager.displayToast(context, message);
        }
        canPayment.value = false;
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      print("p $e");
    }
    isLoading.value = false;
  }

  Future getPaymentStatus(context, String accountCode) async {
    canPayment.value = false;
    try {
      Request request = Request(
          url:
              'GetPOSPaymentStatus?CaptainOrderId=${coNumber}&AccountCode=${accountCode}');
      var value = await request.get();
      if (value.statusCode == 200) {
        canPayment.value = true;
      } else {
        String message = "";
        int statusCode = 0;
        try {
          Map result = jsonDecode(value.body);
          message = (result["Message"] ?? "").toString();
          statusCode = result["StatusCode"] is int ? result["StatusCode"] : 0;
        } catch (_) {}
        if (message.isNotEmpty && (statusCode == 999 || statusCode == 0)) {
          showAlert(context, message);
        }
        canPayment.value = false;
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      canPayment.value = false;
    }
  }
}
