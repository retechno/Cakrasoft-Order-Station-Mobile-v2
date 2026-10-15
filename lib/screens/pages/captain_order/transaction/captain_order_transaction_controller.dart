import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/controllers/special_access_controller.dart';
import 'package:point_of_sales/models/captain_order/captain_order_transaction.dart';
import 'package:point_of_sales/models/payment.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_item_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment_method/payment_method_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment_method/payment_methods_screen.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/mutation_guard.dart';
import 'package:point_of_sales/utils/pending_payment.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:point_of_sales/utils/toast.dart';
import 'package:point_of_sales/utils/uppercase_formatter.dart';
import 'package:point_of_sales/widget/alert_widget.dart';
import 'package:bluetooth_print/bluetooth_print.dart';

enum AmountPercent { amount, percent }

class CaptainOrderTransactionController extends GetxController {
  static CaptainOrderTransactionController get to => Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  RxBool loading = false.obs;
  late Map<String, dynamic> body;
  RxList<CaptainOrderTransaction> captainOrderTransactionList =
      <CaptainOrderTransaction>[].obs;
  RxList<Payment> paymentList = <Payment>[].obs;
  //override price
  TextEditingController oldPriceController = TextEditingController();
  TextEditingController newPriceController = TextEditingController();

  // user access
  SpecialAccessController specialAccessController = SpecialAccessController();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int _accessId = 0;
  RxBool hidePassword = true.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingIndicator = false.obs;
  RxString accessStatus = "".obs;

  //discount
  List<bool> amountPercent = [true, false];
  RxBool isPercent = false.obs;
  RxInt discountType = 3.obs;
  bool isPrinterServiceExist = false;
  TextEditingController discountController = TextEditingController();

  // Debounce per item (key = id transaksi) supaya perubahan qty item lain
  // tidak membatalkan update item yang sedang menunggu dikirim.
  final Map<int, Timer> _quantityTimers = {};

  RxBool isCaptainOrderStatusOpen = false.obs;
  RxInt id = Get.find<CaptainOrderItemController>().id;
  RxDouble totalTransactionPrice = 0.00.obs;
  RxString outletCode = "".obs;
  RxMap captainOrder = {}.obs;
  RxMap summary = {
    "subTotal": 0.0,
    "discount": 0.0,
    "afterDiscount": 0.0,
    "service": 0.0,
    "tax": 0.0,
    "grandTotal": 0.0,
    "total": 0.0,
    "totalPayment": 0.0
  }.obs;

  // Bluetooth-related variables
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  RxBool connected = false.obs;
  RxString tips = 'no device connect'.obs;

  CaptainOrderTransactionController();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    loadCaptainOrder();
    loadCaptainOrderTransactionList();
    // initBluetooth(); // Initialize Bluetooth when the controller is initialized
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

  @override
  Future<void> onClose() async {
    for (final t in _quantityTimers.values) {
      t.cancel();
    }
    _quantityTimers.clear();
    // Clear order list
    var captainOrderItemController = Get.find<CaptainOrderItemController>();
    var orderController = Get.find<OrdersController>();
    captainOrderItemController.loadCaptainOrderList();
    orderController.orderList.clear();
    orderController.totalPrices();
  }

//API
  Future saveSpecialAccess(BuildContext context,
      CaptainOrderTransaction transaction, userId, password, accessMode) async {
    var res = await specialAccessController.specialAccess(
        userId, password, accessMode);
    if (!context.mounted) return;
    String message = "You don't have access";
    if (res) {
      if (accessMode ==
          specialAccessController.userSpecialAccess.reduceQuantity) {
        message = "The item quantity has been changed";
        authorizeQuantity(context);
      }
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

  Future authorizeQuantity(context) async {
    Map data = {"AuthorizeId": _accessId};
    Request request =
        Request(url: 'ChangeQuantityAuthorize', body: jsonEncode(data));
    try {
      var res = await request.put();
      if (res.statusCode == 200) {
        loadCaptainOrderTransactionList();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("The item quantity has been changed."),
        ));
        // Future.delayed(Duration(milliseconds: 0), () => {loadCaptainOrderTransactionList()});
      }
    } catch (e) {
      printError();
    }
  }

  /// Memuat transaksi captain order. Mengembalikan true bila data berhasil
  /// dimuat dan total sudah dihitung ulang.
  Future<bool> loadCaptainOrderTransactionList() async {
    captainOrderTransactionList.clear();
    isLoading.value = true;
    try {
      Request request = Request(url: 'CaptainOrderTransactions?id=$id');
      var value = await request.get();
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        List jsonResponse = result["Result"] ?? [];
        paymentList.clear();
        captainOrderTransactionList.clear();
        if (jsonResponse.isEmpty) {
          totalPrices();
          isLoading.value = false;
          return true;
        }
        for (var el in jsonResponse) {
          if (el["TypeCode"] == "C") {
            paymentList.add(Payment.fromJson(el));
          } else {
            captainOrderTransactionList
                .add(CaptainOrderTransaction.fromJson(el));
          }
        }
        totalPrices();
        isLoading.value = false;
        return true;
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("error: $e");
      }
    }
    isLoading.value = false;
    return false;
  }

  Future loadCaptainOrder() async {
    Request request = Request(url: 'CaptainOrder?id=$id');
    request.get().then((value) {
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        if (result["Result"] == null) return;
        captainOrder.value = result["Result"];
        outletCode.value = captainOrder["OutletCode"];
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    }).catchError((onError) {
      printError();
    });
  }

  Future processPrintToKitchen(context, int type) async {
    await checkPrinterService(context);
    if (isPrinterServiceExist) {
      await printToKitchen(context, type);
    }
  }

  Future printToKitchen(context, int type) async {
    var idList =
        captainOrderTransactionList.map((element) => element.iDLog).toList();
    print("isi $idList");
    Map data = {
      "captain_order_id": id.value,
      "captain_order_transaction_id_list": idList.toString(),
      "is_remove": type == 1 ? "1" : "0",
      "is_cancel": type == 2 ? "1" : "0",
    };
    Request request =
        Request(url: 'GetPrintToKitchenData', body: jsonEncode(data));
    var value = await request.post();
    if (Request.isUncertain(value)) {
      showAlert(context, "Cannot reach the server");
      return;
    }
    if (value.statusCode == 200) {
      Map body = jsonDecode(value.body);
      Map? result = body["Result"];
      if (result == null) {
        showAlert(context, "Nothing to print");
        return;
      }
      if (result["printers1"] == null && result["printers2"] == null) {
        showAlert(context, "Printer not setup on product");
      } else {
        sendDataToPrint(context, result);
      }
    } else {
      if (kDebugMode) {
        print('Backend error');
      }
    }
  }

  Future checkPrinterService(context) async {
    isPrinterServiceExist = false;
    try {
      Request request = Request(url: 'ping', portX: "55678");
      var value = await request.post();
      if (Request.isUncertain(value)) {
        showAlert(context, "Printer Service not found");
        return;
      }
      if (value.statusCode == 200) {
        isPrinterServiceExist = true;
        // showAlert(context, result);
      } else {
        // showAlert(context, result);
        // if (kDebugMode) {
        //   print('Backend error');
        // }
      }
    } catch (e) {
      showAlert(context, e.toString());
      print('Backend error $e');
    }
  }

  Future sendDataToPrint(context, Map data) async {
    try {
      Request request =
          Request(url: 'print', portX: "55678", body: jsonEncode(data));
      var value = await request.post();

      if (Request.isUncertain(value)) {
        showAlert(context, "Printer Service not found");
        return;
      }
      var result = value.body;
      if (value.statusCode == 200) {
        showAlert(context, result);
      } else {
        showAlert(context, result);
        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      showAlert(context, e.toString());
      print('Backend error $e');
    }
  }

  Future getIsCaptainOrderStatusOpen(context) async {
    isLoadingIndicator.value = true;
    isCaptainOrderStatusOpen.value = false;
    try {
      Request request = Request(url: 'IsCaptainOrderStatusOpen/$id');
      var value = await request.get();
      if (Request.isUncertain(value)) {
        // koneksi bermasalah: jangan dianggap "closed by other user"
        isLoadingIndicator.value = false;
        ToastManager.displayToast(context, "Cannot reach the server");
        return;
      }
      if (value.statusCode == 200) {
        Map body = jsonDecode(value.body);
        bool result = body["Result"] == true;
        isCaptainOrderStatusOpen.value = result;
      } else {
        Map result = jsonDecode(value.body);
        String message = result["Message"];

        ToastManager.displayToast(context, message);

        if (kDebugMode) {
          print('Backend error');
        }
      }
    } catch (e) {
      print("p $e");
    }
    isLoadingIndicator.value = false;
  }

  Future<void> toPaymentMethods(context) async {
    // Ada pembayaran yang jawabannya belum pasti (timeout / app mati)?
    final pending = await PendingPayment.find(id.value);
    if (pending != null) {
      await loadCaptainOrderTransactionList();
      await PendingPayment.clear(id.value);
      final amount = Formats.formatNumber((pending["amount"] ?? 0).toString());
      showAlert(
          context,
          "Pembayaran ${pending["account"]} sebesar $amount "
          "(${pending["at"]}) belum terkonfirmasi. Data transaksi sudah "
          "dimuat ulang: periksa ringkasan Payment sebelum membayar lagi.");
      return;
    }
    await getIsCaptainOrderStatusOpen(context);
    if (isCaptainOrderStatusOpen.value) {
      final PaymentMethodController paymentController =
          Get.put(PaymentMethodController());
      paymentController.loadPaymentMethod(context, outletCode);
      Get.to(() => PaymentMethodsScreen());
    } else {
      showAlertCOClosed(context);
    }
  }

  void showAlertCOClosed(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertWidget(
          title: "Information",
          content: "Captain Order has closed by other user.",
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

  Future removeItem(BuildContext context, transactionId) =>
      MutationGuard.run('co:${id.value}:remove:$transactionId',
          () => _removeItem(context, transactionId));

  Future _removeItem(BuildContext context, transactionId) async {
    Request request = Request(url: 'RemoveItem/$transactionId');
    var value = await request.put();
    if (value.statusCode == 200) {
      loadCaptainOrderTransactionList();
    }
    if (!context.mounted) return;
    if (Request.isUncertain(value)) {
      _toast(context, "Cannot reach the server");
      return;
    }
    if (value.statusCode == 200) {
      var body = jsonDecode(value.body);
      String message = "The item has been removed!";
      if (body["Message"] != "") {
        message = body["Message"];
      }

      loadCaptainOrderTransactionList();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    } else {
      if (kDebugMode) {
        print('Backend error');
      }
    }
  }

  Future removeAllItem(context) => MutationGuard.run(
      'co:${id.value}:removeAll', () => _removeAllItem(context));

  Future _removeAllItem(context) async {
    Request request = Request(url: 'RemoveAllItem/$id');
    var value = await request.put();
    if (Request.isUncertain(value)) {
      _toast(context, "Cannot reach the server");
      return;
    }
    if (value.statusCode == 200) {
      var body = jsonDecode(value.body);
      String message = "All item has been removed!";
      if (body["Message"] != "") {
        message = body["Message"];
      }
      loadCaptainOrderTransactionList();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    } else {
      if (kDebugMode) {
        print('Backend error');
      }
    }
  }

  /// Parse angka input user; menerima koma atau titik sebagai desimal.
  /// Mengembalikan null bila tidak valid.
  num? parseAmount(String text) {
    final cleaned = text.trim().replaceAll(',', '.');
    if (!RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(cleaned)) return null;
    return num.tryParse(cleaned);
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future overridePrice(context, transactionId) =>
      MutationGuard.run('co:${id.value}:override:$transactionId',
          () => _overridePrice(context, transactionId));

  Future _overridePrice(context, transactionId) async {
    final amount = parseAmount(newPriceController.text);
    if (amount == null) {
      _toast(context, "Invalid price");
      return;
    }
    Map data = {"TransactionId": transactionId, "Amount": amount};
    Request request = Request(url: 'OverridePrice', body: jsonEncode(data));
    var value = await request.put();
    if (Request.isUncertain(value)) {
      _toast(context, "Cannot reach the server");
      return;
    }
    if (value.statusCode == 200) {
      var body = jsonDecode(value.body);
      String message = "The item price has been override!";
      if (body["Message"] != "") {
        message = body["Message"];
      }
      loadCaptainOrderTransactionList();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    } else {
      if (kDebugMode) {
        print('Backend error');
      }
    }
  }

  Future<int> changeQuantity(context, transactionId, quantity) async {
    _accessId = 0;
    Map data = {"TransactionId": transactionId, "Quantity": quantity};
    Request request = Request(url: 'ChangeQuantity', body: jsonEncode(data));
    try {
      var value = await request.put();
      if (value.statusCode == 200) {
        var body = jsonDecode(value.body);
        String message = "The item quantity has been change!";
        if (body["Message"] != "") {
          message = body["Message"];
        }

        if (message == "Need Access First") {
          _accessId = body["Result"];
        }
        loadCaptainOrderTransactionList();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    } catch (err) {
      printError();
    }
    return _accessId;
  }

  Future discount(context, transactionId) =>
      MutationGuard.run('co:${id.value}:discount:$transactionId',
          () => _discount(context, transactionId));

  Future _discount(context, transactionId) async {
    final amount = parseAmount(discountController.text);
    if (amount == null) {
      _toast(context, "Invalid discount");
      return;
    }
    if (transactionId == null && captainOrderTransactionList.isEmpty) {
      _toast(context, "No item to discount");
      return;
    }
    Map data = {
      "TransactionId": transactionId ?? captainOrderTransactionList[0].iDLog,
      "IsPercent": isPercent.value,
      "DiscountType": discountType.value,
      "Amount": amount
    };
    Request request = Request(url: 'Discount', body: jsonEncode(data));
    var value = await request.put();
    if (Request.isUncertain(value)) {
      _toast(context, "Cannot reach the server");
      return;
    }
    if (value.statusCode == 200) {
      var body = jsonDecode(value.body);
      discountController.clear();
      discountType.value = 3;
      String message = "Discount has been applied!";
      if (body["Message"] != "") {
        message = body["Message"];
      }
      loadCaptainOrderTransactionList();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    } else {
      if (kDebugMode) {
        print('Backend error');
      }
    }
  }

  void changeAmountPercent(index) {
    isPercent.value = index;
    update();
  }

  void totalPrices() {
    totalTransactionPrice.value = 0;
    summary["discount"] = 0.0;
    summary["tax"] = 0.0;
    summary["service"] = 0.0;
    summary["subTotal"] = 0.0;
    summary["grandTotal"] = 0.0;
    summary["afterDiscount"] = 0.0;
    summary["total"] = 0.0;
    summary["totalPayment"] = 0.0;
    for (var element in captainOrderTransactionList) {
      if (element.quantity <= 0) continue;
      final discount = element.discount ?? 0;
      final tax = element.tax ?? 0;
      final service = element.service ?? 0;
      final subTotal = element.subTotal ?? 0;
      final total = element.total ?? 0;
      if (discount > 0) summary["discount"] += discount;
      if (tax > 0) summary["tax"] += tax;
      if (service > 0) summary["service"] += service;
      if (subTotal > 0) summary["subTotal"] += subTotal;
      if (total > 0) summary["grandTotal"] += total;
    }
    for (var element in paymentList) {
      final amount = element.amount ?? 0;
      if (amount > 0) {
        summary["totalPayment"] += amount;
      }
    }
    summary["afterDiscount"] = summary["subTotal"] - summary["discount"];
    summary["total"] = summary["grandTotal"] - summary["totalPayment"];
    totalTransactionPrice.value = summary["grandTotal"];
    captainOrderTransactionList.refresh();
    summary.refresh();
  }

  getTotalOrderPriceText() {
    return Formats.formatNumber(totalTransactionPrice.value.toString());
  }

  Future removeItemOrder(BuildContext context,
      CaptainOrderTransaction transaction, isOrder) async {
    if (transaction.quantity > 1) {
      transaction.quantity--;
      totalPrices();
      captainOrderTransactionList.refresh();
      _scheduleQuantityUpdate(context, transaction);
    }
  }

  Future addItemOrder(BuildContext context, CaptainOrderTransaction transaction,
      isOrder) async {
    transaction.quantity++;
    totalPrices();
    captainOrderTransactionList.refresh();
    _scheduleQuantityUpdate(context, transaction);
  }

  void _scheduleQuantityUpdate(
      BuildContext context, CaptainOrderTransaction transaction) {
    final key = transaction.iDLog ?? 0;
    _quantityTimers[key]?.cancel();
    _quantityTimers[key] =
        Timer(const Duration(milliseconds: 1500), () async {
      _quantityTimers.remove(key);
      if (!context.mounted) return;
      await getIsCaptainOrderStatusOpen(context);
      if (!context.mounted) return;
      if (!isCaptainOrderStatusOpen.value) {
        return showAlertCOClosed(context);
      }
      var a = await changeQuantity(
          context, transaction.iDLog, transaction.quantity);
      if (!context.mounted) return;
      if (a > 0) {
        showModalAccess(context, transaction);
      }
    });
  }

  Future increase(BuildContext context, CaptainOrderTransaction transaction,
      isOrder) async {
    return addItemOrder(context, transaction, isOrder);
  }

  Future decrease(BuildContext context, CaptainOrderTransaction transaction,
      isOrder) async {
    return await removeItemOrder(context, transaction, isOrder);
  }

  Future<void> showModalAccess(context, transaction) {
    userController.text = "";
    passwordController.text = "";
    return showModalBottomSheet<void>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Obx(
            () => FractionallySizedBox(
              heightFactor: 0.9,
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          const Icon(Icons.key_outlined),
                          SizedBox(height: 5),
                          Text(
                            "Authorize",
                            style: Styles.headLineStyle3,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Form(
                            key: _formKey,
                            child: Flexible(
                                child: Column(
                              children: [
                                TextFormField(
                                  autofocus: true,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [UpperCaseTextFormatter()],
                                  style: Styles.textStyle,
                                  controller: userController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(5, 15, 5, 0),
                                    hintText: "User ID",
                                    prefixIcon:
                                        Icon(Icons.person_outline_rounded),
                                  ),
                                  validator: (String? value) {
                                    if (value!.trim().isEmpty) {
                                      return 'User ID is required';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                    style: Styles.textStyle,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    obscureText: hidePassword.value,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    onFieldSubmitted: (value) {
                                      if (_formKey.currentState!.validate()) {
                                        saveSpecialAccess(
                                            context,
                                            transaction,
                                            userController.text,
                                            passwordController.text,
                                            specialAccessController
                                                .userSpecialAccess
                                                .reduceQuantity);
                                        Navigator.pop(context);
                                      }
                                    },
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                5, 15, 5, 0),
                                        hintText: "Password",
                                        prefixIcon: const Icon(
                                            Icons.lock_outline_rounded),
                                        suffixIcon: InkWell(
                                            onTapDown: (detail) {
                                              hidePassword.value =
                                                  !hidePassword.value;
                                            },
                                            onTapUp: (detail) {
                                              hidePassword.value =
                                                  !hidePassword.value;
                                            },
                                            child: const Icon(Icons
                                                .remove_red_eye_outlined))),
                                    validator: (String? value) {
                                      if (value!.trim().isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 6) {
                                        return 'Password is too short.';
                                      }
                                      return null;
                                    }),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      saveSpecialAccess(
                                          context,
                                          transaction,
                                          userController.text,
                                          passwordController.text,
                                          specialAccessController
                                              .userSpecialAccess
                                              .reduceQuantity);
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ButtonStyle(
                                      minimumSize:
                                          WidgetStateProperty.all<Size>(Size(
                                              double.infinity,
                                              Styles.defaultHeightButton)),
                                      // minimumSize:
                                      //     MaterialStateProperty.all<Size>(Size(double.infinity, Styles.defaultHeightButton)),
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Styles.primaryColor),
                                      shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Styles.defaultRadius),
                                      ))),
                                  child: const Text("Confirm"),
                                ),
                                Text(
                                  accessStatus.value,
                                  style: TextStyle(color: Styles.dangerColor),
                                  textAlign: TextAlign.start,
                                )
                              ],
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  String? floatValidation(String value) {
    final amount = parseAmount(value);
    if (amount == null || amount <= 0) {
      return 'Invalid value';
    }
    return null;
  }
}
