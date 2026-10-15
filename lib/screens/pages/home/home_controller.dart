import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_item_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:point_of_sales/utils/secure_store.dart';

class HomeController extends GetxController {
  RxString user = "".obs;
  RxString userGroup = "".obs;

  RxString cashBalance = "0".obs;
  RxInt finished = 0.obs;
  RxInt cancelled = 0.obs;
  RxInt pending = 0.obs;

  RxList<OutletRevenue> outletRevenueList = <OutletRevenue>[].obs;

  List colorList = [
    Colors.green[100],
    Colors.green[300],
    Colors.green[500],
    Colors.green[700],
    Colors.green[900],
  ];

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadUserData();
  }

  Future loadUserData() async {
    final refs = await SharedPreferences.getInstance();
    user.value = refs.getString("user") ?? "";
    userGroup.value = refs.getString("userGroup") ?? "";
  }

  Future logout() async {
    var prefs = await SharedPreferences.getInstance();

    await TokenStore.clear();
    await prefs.setString("user", "");
    await prefs.setString("userGroup", "");
    user.value = "";
    userGroup.value = "";

    // Bersihkan state kasir sebelumnya agar tidak terlihat oleh user berikutnya.
    if (Get.isRegistered<OrdersController>()) {
      final orders = Get.find<OrdersController>();
      orders.orderList.clear();
      orders.captainOrderId.value = 0;
      orders.totalPrices();
    }
    if (Get.isRegistered<CaptainOrderItemController>()) {
      Get.find<CaptainOrderItemController>().captainOrderItemList.clear();
    }
    Get.offAndToNamed("/login");
  }

  Future loadData() async {
    Request result = Request(url: "Dashboard");
    result.get().then((value) {
      if (value.statusCode == 200) {
        var data = jsonDecode(value.body);
        var res = data["Result"];
        // if (res.isNotEmpty) {
        cashBalance.value = data["Result"]["CashBalance"].toString();
        pending.value = res["Status"]["Pending"] ?? 0;
        finished.value = res["Status"]["Finished"] ?? 0;
        cancelled.value = res["Status"]["Cancelled"] ?? 0;
        List listOutlet = res["OutletRevenue"];
        outletRevenueList.value = listOutlet.map((val) => OutletRevenue.fromJson(val)).toList();
        // print(outletRevenueList.value);
        // }
      }
    }).catchError((onError) {
      printError();
    });
  }
}

class OutletRevenue {
  String? name;
  String? code;
  List<Revenue>? revenue;

  OutletRevenue({this.name, this.code, this.revenue});

  OutletRevenue.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    code = json['Code'];
    if (json['Revenue'] != null) {
      revenue = <Revenue>[];
      json['Revenue'].forEach((v) {
        revenue!.add(new Revenue.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['Code'] = code;
    if (revenue != null) {
      data['Revenue'] = revenue!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Revenue {
  num? revenue;
  String? auditDate;

  Revenue({this.revenue, this.auditDate});

  Revenue.fromJson(Map<String, dynamic> json) {
    revenue = json['Revenue'];
    auditDate = json['AuditDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Revenue'] = revenue;
    data['AuditDate'] = auditDate;
    return data;
  }
}
