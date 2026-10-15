import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/captain_order/captain_order.dart';
import 'package:point_of_sales/models/captain_order/captain_order_transaction.dart';
import 'package:point_of_sales/models/captain_order/compliment_type_model.dart';
import 'package:point_of_sales/models/captain_order/market_model.dart';
import 'package:point_of_sales/models/captain_order/outlet_model.dart';
import 'package:point_of_sales/models/captain_order/sub_department_model.dart';
import 'package:point_of_sales/models/captain_order/table_model.dart';
import 'package:point_of_sales/models/captain_order/title_model.dart';
import 'package:point_of_sales/models/captain_order/waitress_model.dart';
import 'package:point_of_sales/models/order_model.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_item_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_screen.dart';
import 'package:point_of_sales/screens/pages/order/category/category_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/screens/pages/order/orders_page.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/request.dart';

class CaptainOrderController extends GetxController {
  CaptainOrderItemController captainOrderItemController =
      Get.find<CaptainOrderItemController>();
  List<Order> orderList = Get.find<OrdersController>().orderList;
  RxBool loading = false.obs;
  // true selama request simpan order berjalan (cegah double-submit).
  RxBool isSavingOrder = false.obs;
  late Map<String, dynamic> body;

  RxList<ComplimentType> complimentTypeList = <ComplimentType>[].obs;
  RxList<Market> marketList = <Market>[].obs;
  RxList<Outlet> outletList = <Outlet>[].obs;
  RxList<SubDepartment> subDepartmentList = <SubDepartment>[].obs;
  RxList<Tables> tableList = <Tables>[].obs;
  RxList<Titles> titleList = <Titles>[].obs;
  RxList<Waitress> waitressList = <Waitress>[].obs;
  RxList<CaptainOrder> captainOrderItemList = <CaptainOrder>[].obs;

  RxMap captainOrderDropdown = {}.obs;

  RxList captainOrderList = [].obs;

  TextEditingController customerController = TextEditingController();
  TextEditingController adultController = TextEditingController();
  TextEditingController childController = TextEditingController();

  RxInt adult = 1.obs;
  RxInt child = 0.obs;
  TextEditingController remarkController = TextEditingController();
  RxString complimentTypeCode = "N".obs;
  Rxn<String> titleCode = Rxn<String>();
  RxString? marketCode = "PUBL".obs;
  Rxn<String> tableNumber = Rxn<String>();
  Rxn<String> waitressCode = Rxn<String>();
  RxString? memberCode = "".obs;
  RxString? fullName = "".obs;
  RxString? documentNumber = "".obs;
  RxString? companyCode = "".obs;
  Rxn<String> marketingCode = Rxn<String>();
  RxString? timeSegmentCode = "".obs;
  RxString? typeCode = "I".obs;
  Rxn<String> subDepartmentCode = Rxn<String>();
  RxString? isOpen = "-1".obs;
  RxString? isPrinted = "-1".obs;
  RxMap captainOrder = {}.obs;

  RxInt id = 0.obs;
  RxString categoryCode = "".obs;
  RxString outletCode = Get.find<CategoryController>().outletCode;

  @override
  void onReady() {
    super.onReady();
    loadDropdown();
    loadTables();
  }

  void toOrderDetailPage() {
    Get.to(() => OrderDetailScreen());
  }

  void toCaptainOrderDetailPage() {
    Get.to(() => CaptainOrderScreen());
  }

  assignCaptainOrderDetail() {
    if (captainOrder.isEmpty) return;

    customerController.text = captainOrder["FullName"];
    adultController.text = captainOrder["Adult"].toString();
    childController.text = captainOrder["Child"].toString();
    remarkController.text = captainOrder["Remark"];

    complimentTypeCode.value = captainOrder["ComplimentTypeCode"] != ""
        ? captainOrder["ComplimentTypeCode"]
        : null;
    if (captainOrder["TitleCode"] != "") {
      titleCode.value = captainOrder["TitleCode"];
    }
    if (captainOrder["MarketCode"] != "") {
      marketCode?.value = captainOrder["MarketCode"];
    }
    if (captainOrder["TableNumber"] != "") {
      tableNumber.value = captainOrder["TableNumber"];
    }
    if (captainOrder["WaitressCode"] != "") {
      waitressCode.value = captainOrder["WaitressCode"];
    }
    if (captainOrder["MemberCode"] != "") {
      memberCode?.value = captainOrder["MemberCode"];
    }
    if (captainOrder["FullName"] != "") {
      fullName?.value = captainOrder["FullName"];
    }
    if (captainOrder["DocumentNumber"] != "") {
      documentNumber?.value = captainOrder["DocumentNumber"];
    }
    if (captainOrder["CompanyCode"] != "") {
      companyCode?.value = captainOrder["CompanyCode"];
    }
    if (captainOrder["MarketingCode"] != "") {
      marketingCode.value = captainOrder["MarketingCode"];
    }
    if (captainOrder["SubDepartmentCode"] != "") {
      subDepartmentCode.value = captainOrder["SubDepartmentCode"];
    }
  }

  void resetCaptainOrderForm() {
    captainOrder.clear();
    customerController.clear();
    adultController.clear();
    childController.clear();
    remarkController.clear();
    complimentTypeCode.value = "N";
    titleCode = Rxn<String>();
    marketCode?.value = "PUBL";
    tableNumber = Rxn<String>();
    waitressCode = Rxn<String>();
    memberCode?.value = "";
    fullName?.value = "";
    documentNumber?.value = "";
    companyCode?.value = "";
    marketingCode = Rxn<String>();
    subDepartmentCode = Rxn<String>();
    isOpen = "-1".obs;
    isPrinted = "-1".obs;
  }

  loadCaptainOrder(captainOrderId) async {
    Request request = Request(url: 'CaptainOrder?id=$captainOrderId');
    request.get().then((value) {
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        captainOrder.value = result["Result"];
        assignCaptainOrderDetail();
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    }).catchError((onError) {
      if (kDebugMode) {
        print(onError);
      }
      printError();
    });
  }

  Future loadDropdown() async {
    try {
      Request request = Request(url: 'GetCaptainOrderComboList');
      var res = await request.get();
      if (res.statusCode == 200) {
        Map result = jsonDecode(res.body);
        Map jsonResponse = result["Result"];
        convertFromJSON(jsonResponse);
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      // Get.offAllNamed("/urlSetup");
    }
  }

  Future loadTables() async {
    try {
      Request request = Request(url: 'Tables?code=$outletCode');
      var res = await request.get();
      if (res.statusCode == 200) {
        Map result = jsonDecode(res.body);
        List jsonResponse = result["Result"];
        tableList.value = jsonResponse.map((e) => Tables.fromJson(e)).toList();
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      // Get.offAllNamed("/urlSetup");
    }
  }

  loadCheckList() async {
    try {
      Request request = Request(url: 'Tables?code=$outletCode');
      var res = await request.get();
      if (res.statusCode == 200) {
        Map result = jsonDecode(res.body);
        List jsonResponse = result["Result"];
        tableList.value = jsonResponse.map((e) => Tables.fromJson(e)).toList();
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      // Get.offAllNamed("/urlSetup");
    }
  }

  /// Mengembalikan 0 HANYA bila server menjawab sukses (HTTP 200).
  /// Nilai lain berarti gagal / belum pasti, dan order list tidak boleh dihapus.
  Future<int> createCaptainOrder(
      BuildContext context, int captainOrderId) async {
    if (isSavingOrder.value) return -2;
    isSavingOrder.value = true;
    try {
      return await _createCaptainOrder(context, captainOrderId);
    } catch (e) {
      if (kDebugMode) {
        print('createCaptainOrder error $e');
      }
      showAlert(context,
          "Koneksi terputus atau server tidak merespons. Order mungkin sudah tersimpan, periksa daftar Captain Order sebelum menyimpan ulang.");
      return -1;
    } finally {
      isSavingOrder.value = false;
    }
  }

  Future<int> _createCaptainOrder(
      BuildContext context, int captainOrderId) async {
    int statusCode = 0;
    List dataT = orderList
        .map((e) => CaptainOrderTransaction(
                captainOrderId: captainOrderId,
                productCode: e.productCode,
                quantity: e.quantity,
                remark: e.remark)
            .toJson())
        .toList();
    CaptainOrder data = CaptainOrder(
        idLog: captainOrderId,
        adult: adult.value,
        child: child.value,
        fullName: customerController.text,
        marketCode: marketCode?.value,
        subDepartmentCode: subDepartmentCode.value,
        complimentTypeCode: complimentTypeCode.value,
        waitressCode: waitressCode.value,
        outletCode: outletCode.value,
        tableNumber: tableNumber.value,
        remark: remarkController.text,
        typeCode: typeCode?.value);
    Map dataC = {"CaptainOrder": data.toJson(), "TransactionOrder": dataT};
    Request request = Request(
        url: 'InsertCaptainOrderWithTransaction', body: jsonEncode(dataC));
    var res = await request.post();
    if (Request.isUncertain(res)) {
      if (!context.mounted) return -1;
      showAlert(context,
          "Koneksi terputus. Order mungkin sudah tersimpan, periksa daftar Captain Order sebelum menyimpan ulang.");
      return -1;
    }
    if (res.statusCode == 200) {
      body = jsonDecode(res.body);
      captainOrderItemController.id.value = body["Result"];
      resetCaptainOrderForm();
      // if (captainOrderId > 0) {
      //   captainOrderItemController.id.value = captainOrderId;
      //   var transactionController = Get.find<CaptainOrderTransactionController>();
      //   transactionController.loadCaptainOrderTransactionList();
      // }
    } else {
      String message = "";
      int code = 0;
      try {
        final errorBody = jsonDecode(res.body);
        message = (errorBody["Message"] ?? "").toString();
        code = errorBody["StatusCode"] is int ? errorBody["StatusCode"] : 0;
      } catch (_) {}
      // Apa pun isi body, non-200 adalah GAGAL (jangan pernah dianggap sukses).
      statusCode = code > 0 ? code : -1;
      if (!context.mounted) return statusCode;
      showAlert(context, message != "" ? message : "Gagal menyimpan order");

      if (kDebugMode) {
        print('Backend error');
      }
    }
    return statusCode;
  }

  void convertFromJSON(Map json) {
    if (json['Title'] != null) {
      List jsonList = json['Title'];
      titleList.value = [];
      titleList.value = jsonList.map((e) => Titles.fromJson(e)).toList();
    }
    if (json['ComplimentType'] != null) {
      List jsonList = json['ComplimentType'];
      complimentTypeList.value =
          jsonList.map((e) => ComplimentType.fromJson(e)).toList();
    }
    if (json['SubDepartment'] != null) {
      List jsonList = json['SubDepartment'];
      subDepartmentList.value =
          jsonList.map((e) => SubDepartment.fromJson(e)).toList();
    }
    if (json['Outlet'] != null) {
      List jsonList = json['Outlet'];
      outletList.value = jsonList.map((e) => Outlet.fromJson(e)).toList();
    }
    if (json['Waitress'] != null) {
      List jsonList = json['Waitress'];
      waitressList.value = jsonList.map((e) => Waitress.fromJson(e)).toList();
    }
    if (json['Market'] != null) {
      List jsonList = json['Market'];
      marketList.value = jsonList.map((e) => Market.fromJson(e)).toList();
    }
  }
}
