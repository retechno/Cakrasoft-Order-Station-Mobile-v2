import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:point_of_sales/models/report/check.dart';
import 'package:point_of_sales/models/report/captain_order.dart';
// import 'package:bonsoir/bonsoir.dart';

class PrintReceiptController extends GetxController {
  RxList<String> printers = <String>[].obs;
  RxList<Products> productListFilters = <Products>[].obs;
  // final Rx<PrintCaptainOrderData> printCaptainOrderData =
  //     PrintCaptainOrderData().obs;
  Rx<CaptainOrder> captainOrder = CaptainOrder().obs;
  Rx<Company> company = Company(code: "").obs;
  RxList<Transaction> transaction = <Transaction>[].obs;
  RxList<PaymentCaptainOrder> payment = <PaymentCaptainOrder>[].obs;

  Rx<Check> check = Check().obs;
  RxList<CheckTransaction> checkTransaction = <CheckTransaction>[].obs;
  RxList<Payment> checkPayment = <Payment>[].obs;

  PrintCaptainOrderData printCaptainOrderData2 = PrintCaptainOrderData();
  int port = 9100;

  int found = 0;
  RxInt captainOrderId = 0.obs;
  RxInt isDiscovering = 0.obs;
  RxInt isPrinting = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrintCaptainOrderData();
  }

  // Scan hanya dijalankan saat dialog printer dibuka (bukan saat layar dibuka).
  Future<void>? _discovering;

  /// Scan berjalan satu per satu: pemanggilan saat scan masih berjalan
  /// mengembalikan Future yang sama (FutureBuilder di dialog sering
  /// memanggil ulang ini setiap rebuild).
  Future<void> discoverPrinters() {
    return _discovering ??= _discoverPrinters().whenComplete(() {
      _discovering = null;
    });
  }

  Future<void> _discoverPrinters() async {
    isDiscovering.value = 1;
    printers.clear();
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.wifi) {
        final networkInfo = NetworkInfo();
        final ip = await networkInfo.getWifiIP();
        if (ip == null || !ip.contains('.')) {
          isDiscovering.value = 0;
          return;
        }
        final String subnet = ip.substring(0, ip.lastIndexOf('.'));

        final stream = NetworkAnalyzer.discover2(subnet, port);
        stream.listen((NetworkAddress addr) {
          if (addr.exists) {
            printers.add(addr.ip);
            found = printers.length;
          }
        })
          ..onDone(() {
            isDiscovering.value = 0;
            found = printers.length;
          })
          ..onError((dynamic e) {
            isDiscovering.value = 0;
            print("error: $e");
            // Scaffold.of(ctx).showSnackBar(snackBar);
          });
// Once defined, we can start the discovery :
//         BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
//         await discovery.ready;

// // If you want to listen to the discovery :
//         discovery.eventStream!.listen((event) {
//           if (event.type ==
//               BonsoirDiscoveryEventType.discoveryServiceResolved) {
//             print('Service found : ${event.service.toString()}');
//           } else if (event.type ==
//               BonsoirDiscoveryEventType.discoveryServiceLost) {
//             print('Service lost : ${event.service.toString()}');
//           }
//         });

// Start discovery **after** having listened to discovery events
        // await discovery.start();
      } else {
        print('Wi-Fi is not available.');
      }
    } catch (e) {
      print('Error discovering printers: $e');
    }

    await new Future.delayed(new Duration(seconds: 5), () {
      isDiscovering.value = 0;
    });
  }

  Future<void> printToKitchen() async {
    int id = captainOrderId.value;
    if (id == 0) return;
    Request request = Request(url: 'PrintToKitchen/$id');
    var value = await request.post();
    if (value.statusCode == 200) {
    } else {
      if (kDebugMode) {
        print('Backend error');
      }
    }
  }

  Future<void> loadPrintCaptainOrderData() async {
    int id = captainOrderId.value;
    transaction.clear();
    payment.clear();
    if (id == 0) return;
    Request request = Request(url: 'GenerateReport?ReportID=80002&Param=$id');
    var value = await request.get();
    if (value.statusCode == 200) {
      Map result = jsonDecode(value.body);
      Map<String, dynamic> jsonResponse = result["Result"];
      Map dataX = jsonResponse["data"];
      List tx = dataX["transactions"];
      List py = dataX["payments"] ?? [];
      captainOrder.value = CaptainOrder.fromJson(dataX["captain_order"]);
      company.value = Company.fromJson(jsonResponse["company"]);
      transaction.value = tx.map((e) => Transaction.fromJson(e)).toList();
      payment.value = py.map((e) => PaymentCaptainOrder.fromJson(e)).toList();
    } else {
      if (kDebugMode) {
        print('Backend error');
      }
    }
  }

  Future<void> loadPrintCheckData(String checkNumber) async {
    if (checkNumber == "") return;
    Request request =
        Request(url: 'GenerateReport?ReportID=80001&Param=$checkNumber');
    var value = await request.get();
    if (value.statusCode == 200) {
      Map result = jsonDecode(value.body);
      Map<String, dynamic> jsonResponse = result["Result"];
      Map dataX = jsonResponse["data"];
      List tx = dataX["transactions"];
      List py = dataX["payments"] ?? [];

      check.value = Check.fromJson(dataX["check"]);
      company.value = Company.fromJson(jsonResponse["company"]);
      checkTransaction.value =
          tx.map((e) => CheckTransaction.fromJson(e)).toList();
      checkPayment.value = py.map((e) => Payment.fromJson(e)).toList();
    } else {
      if (kDebugMode) {
        print('Backend error');
      }
    }
  }
}
