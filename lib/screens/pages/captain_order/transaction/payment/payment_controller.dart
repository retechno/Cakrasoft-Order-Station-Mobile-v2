import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/payment.dart';
import 'package:point_of_sales/models/payment_data.dart';
import 'package:point_of_sales/models/payment_method.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_item_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/payment_success_screen.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/pending_payment.dart';
import 'package:point_of_sales/utils/request.dart';

class PaymentController extends GetxController {
  RxDouble totalTransaction =
      Get.find<CaptainOrderTransactionController>().totalTransactionPrice;
  RxMap summary = Get.find<CaptainOrderTransactionController>().summary;
  RxString accountCode = "".obs;
  RxString accountName = "".obs;
  CaptainOrderTransactionController captainOrderTransactionController =
      Get.find<CaptainOrderTransactionController>();
  RxInt captainOrderId = Get.find<CaptainOrderTransactionController>().id;
  RxDouble totalPayment = 0.00.obs;
  RxBool canPayment = false.obs;
  RxBool isSaving = false.obs;

  Rx<PaymentMethod> paymentMethod = PaymentMethod().obs;

  // Bluetooth-related variables
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  RxBool connected = false.obs;
  RxString tips = 'no device connect'.obs;

  @override
  void onInit() {
    super.onInit();
    initBluetooth(); // Initialize Bluetooth when the controller is initialized
  }

  // Bluetooth initialization function
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          connected.value = true;
          tips.value = 'Connect success';
          break;
        case BluetoothPrint.DISCONNECTED:
          connected.value = false;
          tips.value = 'Disconnect success';
          break;
        default:
          break;
      }
    });

    if (isConnected) {
      connected.value = true;
    }
  }

  getTotalPayment() {
    //
  }

  num get _outstanding =>
      num.tryParse(summary["total"].toString()) ?? 0;

  void _alert(BuildContext context, String message) {
    try {
      showAlert(context, message);
    } catch (_) {
      // context sudah tidak aktif (mis. layar berpindah saat koneksi putus)
    }
  }

  /// Pesan error dari body response server; fallback bila body bukan JSON.
  String _errorMessage(dynamic response, String fallback) {
    try {
      final result = jsonDecode(response.body);
      final message = result["Message"];
      if (message is String && message.isNotEmpty) return message;
    } catch (_) {}
    return fallback;
  }

  static const String _unknownStatusMessage =
      "Koneksi terputus atau server tidak merespons. Status transaksi belum "
      "diketahui. Periksa daftar pembayaran/refresh sebelum mengulang, agar "
      "tidak terjadi pembayaran ganda.";

  insertTransaction(num amount) async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      Map data =
          Payment(accountCode: accountCode.value, amount: amount).toJson();
      Request request =
          Request(url: 'InsertCaptainOrderTransaction', body: jsonEncode(data));
      var value = await request.post();
      if (!Request.isUncertain(value) && value.statusCode != 200 && kDebugMode) {
        print('Backend error');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Backend error $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  insertPayment(context, PaymentData paymentData, num amount) async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      // Pre-flight: server menerima duplikat, jadi pastikan kondisi terbaru
      // sudah termuat sebelum uang dikirim.
      final loaded = await captainOrderTransactionController
          .loadCaptainOrderTransactionList();
      if (!loaded) {
        _alert(context,
            "Tidak dapat memuat data transaksi terbaru. Pembayaran dibatalkan, silakan coba lagi.");
        return;
      }
      // Filter di sisi client: kelebihan bayar hanya boleh untuk cash (kembalian).
      if (paymentMethod.value.subGroupCode != "PYMT" &&
          amount > _outstanding) {
        _alert(context,
            "Jumlah pembayaran (${Formats.formatNumber(amount.toString())}) melebihi sisa tagihan (${Formats.formatNumber((_outstanding > 0 ? _outstanding : 0).toString())}).");
        return;
      }

      paymentData.paymentAmount = amount;
      Map data = paymentData.toJson();
      Request request =
          Request(url: 'InsertPOSPayment', body: jsonEncode(data));
      // Tandai SEBELUM kirim: bila app mati / koneksi putus, kasir akan
      // diminta memverifikasi pembayaran sebelum membayar ulang.
      await PendingPayment.mark(
          captainOrderId.value, accountName.value, amount);
      var value = await request.post();
      if (Request.isUncertain(value)) {
        await captainOrderTransactionController
            .loadCaptainOrderTransactionList();
        _alert(context, _unknownStatusMessage);
        return;
      }
      // Server menjawab pasti (diterima atau ditolak).
      await PendingPayment.clear(captainOrderId.value);
      if (value.statusCode == 200) {
        await captainOrderTransactionController
            .loadCaptainOrderTransactionList();
        onPaymentSuccess(context);
      } else {
        _alert(context, _errorMessage(value, "Pembayaran gagal."));
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      // Timeout / error tak terduga: hasil di server tidak pasti.
      try {
        await captainOrderTransactionController
            .loadCaptainOrderTransactionList();
      } catch (_) {}
      _alert(context, _unknownStatusMessage);
      if (kDebugMode) {
        print('insertPayment error $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  finishSale(context) async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      final loaded = await captainOrderTransactionController
          .loadCaptainOrderTransactionList();
      if (!loaded) {
        _alert(context,
            "Tidak dapat memuat data transaksi terbaru. Silakan coba lagi.");
        return;
      }
      // Hitung kembalian dari data terbaru sebelum order ditutup.
      final outstanding = _outstanding;
      final String refund = outstanding < 0 ? (-outstanding).toString() : "0";

      Request request = Request(url: 'FinishSale/${captainOrderId}');
      var value = await request.post();
      if (Request.isUncertain(value)) {
        _alert(context, _unknownStatusMessage);
        return;
      }
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        String checkNumber = (result["Result"] ?? "").toString();

        CaptainOrderItemController captainOrderItemController =
            Get.put(CaptainOrderItemController());
        captainOrderItemController.loadCaptainOrderList();
        Get.off(() => PaymentSuccessfulScreen(
              checkNumber: checkNumber,
              totalChange: refund,
            ));
      } else {
        _alert(context, _errorMessage(value, "Finish sale gagal."));
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      _alert(context, _unknownStatusMessage);
      if (kDebugMode) {
        print('finishSale error $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  void confirmPayment(
      BuildContext context, num amount, PaymentData paymentData) {
    if (amount <= 0 || isSaving.value) return;
    insertPayment(context, paymentData, amount);
  }

  /// Dipanggil setelah payment tersimpan dan transaksi sudah dimuat ulang,
  /// sehingga `summary["total"]` adalah sisa tagihan terkini.
  onPaymentSuccess(context) {
    if (_outstanding <= 0.005) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
                title: const Text('Payment Successful'),
                content: const Text(
                  'Are you want to close captain order?',
                  style: TextStyle(fontSize: 20),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.pop(context); // Close the payment screen
                    },
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Styles.primaryColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      finishSale(context);
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ));
    } else {
      Navigator.pop(context);
    }
  }
}
