// ignore_for_file: use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:point_of_sales/models/captain_order/captain_order_transaction.dart';
import 'package:point_of_sales/screens/pages/captain_order/captain_order_item_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/payment_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment_method/payment_method_controller.dart';
import 'package:point_of_sales/screens/pages/order/category/category_screen.dart';
import 'package:point_of_sales/screens/pages/order/orders_controller.dart';
import 'package:point_of_sales/screens/pages/print_receipt/print_receipt_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/printer.dart';
import 'package:point_of_sales/utils/uppercase_formatter.dart';
import 'package:point_of_sales/widget/skeleton_list_widget.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';

class CaptainOrderTransactionScreen
    extends GetView<CaptainOrderTransactionController> {
  @override
  final CaptainOrderTransactionController controller =
      Get.put(CaptainOrderTransactionController());
  final PaymentMethodController paymentController =
      Get.put(PaymentMethodController());
  final CaptainOrderItemController captainOrderItemController =
      Get.find<CaptainOrderItemController>();
  final OrdersController orderController = Get.find<OrdersController>();
  final GlobalKey<FormState> _formKeyUserAccess = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PrintReceiptController printController =
      Get.put(PrintReceiptController());

  CaptainOrderTransactionScreen({Key? key}) : super(key: key);

  Future<void> _loadData() async {
    controller.loadCaptainOrder();
    controller.loadCaptainOrderTransactionList();
  }

  Future<void> _toCategories(context) async {
    await controller.getIsCaptainOrderStatusOpen(context);
    if (!controller.isCaptainOrderStatusOpen.value) {
      return controller.showAlertCOClosed(context);
    }
    // Get
    Get.off(() => CategoryScreen(), arguments: [
      {
        "captainOrderId": controller.id,
        "captainOrderTransactionList": controller.captainOrderTransactionList
      }
    ]);
    orderController.loadArgument();
  }

  Future _saveSpecialAccess(BuildContext context,
      CaptainOrderTransaction? transaction, accessMode) async {
    var res = await controller.specialAccessController.specialAccess(
        controller.userController.text,
        controller.passwordController.text,
        accessMode);
    Navigator.pop(context);
    String message = "You don't have access";

    if (res) {
      if (accessMode ==
          controller.specialAccessController.userSpecialAccess.removeItem) {
        if (transaction == null) {
          return controller.removeAllItem(context);
        }
        await controller.removeItem(context, transaction.iDLog);
      } else if (accessMode ==
          controller.specialAccessController.userSpecialAccess.discount) {
        showModalBottomDiscount(context, transaction?.iDLog);
      } else if (accessMode ==
          controller.specialAccessController.userSpecialAccess.overridePrice) {
        showModalBottomOverride(context, transaction!);
        // overridePrice(context, transaction.iDLog);
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Styles.bgColor,
      body: Obx(
        () => ModalProgressHUD(
          inAsyncCall: printController.isPrinting.value > 0 ||
              controller.isLoadingIndicator.value,
          child: Container(
            width: size.width,
            padding: Styles.paddingBody,
            child: Column(
              children: [
                TitleHeaderWidget(
                  context,
                  title: "Captain Order #${controller.id}",
                  titleDetail: controller.captainOrder["Outlet"],
                  options: PopupMenuButton<int>(
                    onSelected: (item) => handleClickPopUpMenu(context, item),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                          value: 0, child: Text('Print to Kitchen')),
                      PopupMenuItem<int>(value: 1, child: Text('Print CO')),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Table",
                          style: Styles.textDetailStyle,
                        ),
                        Text(controller.captainOrder.isEmpty
                            ? "-"
                            : controller.captainOrder["TableNumber"] == ""
                                ? "-"
                                : controller.captainOrder["TableNumber"])
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Guests",
                          style: Styles.textDetailStyle,
                        ),
                        Text(controller.captainOrder.isEmpty
                            ? "-"
                            : (controller.captainOrder["Adult"] +
                                    controller.captainOrder["Child"])
                                .toString())
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Customer",
                          style: Styles.textDetailStyle,
                        ),
                        Text(controller.captainOrder.isEmpty
                            ? "-"
                            : controller.captainOrder["FullName"] == ""
                                ? "-"
                                : controller.captainOrder["FullName"])
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Compliment Type",
                          style: Styles.textDetailStyle,
                        ),
                        Text(controller.captainOrder.isEmpty
                            ? "-"
                            : controller.captainOrder["ComplimentType"] == ""
                                ? "-"
                                : controller.captainOrder["ComplimentType"])
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width,
                  child: Text(
                    "Order Info",
                    textAlign: TextAlign.start,
                    style: Styles.headLineStyle4,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Items",
                      style: Styles.textDetailStyle,
                    ),
                    Text(
                      "Price",
                      style: Styles.textDetailStyle,
                    )
                  ],
                ),
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: controller.isLoading.value
                      ? ItemListSkeleton(
                          itemCount: 5,
                          itemHeight: Styles.defaultHeightCard,
                          itemPadding: EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: Styles.defaultPadding / 2),
                          listPadding: EdgeInsets.only(
                              top: Styles.defaultPadding,
                              bottom: Styles.defaultPadding,
                              left: 5,
                              right: 5),
                          isHorizontal: false,
                        )
                      : (controller.captainOrderTransactionList.isNotEmpty
                          ? ListView(
                              children: List.generate(
                                  controller.captainOrderTransactionList.length,
                                  (index) {
                              return itemList(
                                  context,
                                  size,
                                  controller
                                      .captainOrderTransactionList[index]);
                            }))
                          : RefreshIndicator(
                              onRefresh:
                                  _loadData, // Call _loadData on pull-to-refresh
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("No data found"),
                                    ElevatedButton(
                                      onPressed:
                                          _loadData, // Trigger refresh on button press
                                      child: const Text("Refresh"),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                )),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total",
                              style: Styles.headLineStyle4,
                            ),
                            InkWell(
                              onTap: () {
                                controller.totalPrices();
                                bottomPaymentDetail(context, size);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    Formats.formatNumber(
                                        controller.summary["total"].toString()),
                                    style: Styles.textStyle,
                                  ),
                                  const Icon(Icons.expand_less)
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  controller.captainOrderTransactionList
                                          .isNotEmpty
                                      ? _delete(context)
                                      : null;
                                },
                                child: const SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Icon(Icons.delete_outline))),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all<Size>(
                                      Size(size.width / 4, 38)),
                                  foregroundColor: WidgetStateProperty.all<
                                      Color>(Colors.white),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          controller.captainOrderTransactionList
                                                  .isNotEmpty
                                              ? Styles.primaryColor
                                              : Styles.disabledColor),
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Styles.defaultRadius),
                                  ))),
                              onPressed: () {
                                controller
                                        .captainOrderTransactionList.isNotEmpty
                                    ? (controller.captainOrder[
                                                "ComplimentTypeCode"] ==
                                            "N"
                                        ? controller.toPaymentMethods(context)
                                        : showConfirmDialog(context))
                                    : null;
                              },
                              child: controller
                                          .captainOrder["ComplimentTypeCode"] ==
                                      "N"
                                  ? const Text('Payment')
                                  : const Text('Finish Sale'),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                _toCategories(context);
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Styles.defaultRadius),
                                    color: Styles.primaryColor),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  handleClickPopUpMenu(context, int item) async {
    if (item == 0) {
      controller.isLoadingIndicator.value = true;
      await controller.processPrintToKitchen(context, 0);
      controller.isLoadingIndicator.value = false;
    } else if (item == 1) {
      selectPrinterDialogX(context);
    }
  }

  void showConfirmDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure ?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context, false); // Dismiss the dialog, return false
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Dismiss the dialog, return true
              },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Styles.primaryColor),
              ),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        PaymentController paymentController = Get.put(PaymentController());
        // Proceed with the "Finish Sale" action since the user confirmed
        paymentController.finishSale(context);
      }
      // Else, do nothing or handle the cancel action
    });
  }

  Future<void> _delete(BuildContext context) async {
    await controller.getIsCaptainOrderStatusOpen(context);
    if (!controller.isCaptainOrderStatusOpen.value) {
      return controller.showAlertCOClosed(context);
    }
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to remove all transaction?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showModalAccess(
                        context,
                        null,
                        controller.specialAccessController.userSpecialAccess
                            .removeItem);
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'))
            ],
          );
        });
  }

  Card itemList(BuildContext context, size, orderList) {
    return Card(
      child: Container(
        height: Styles.defaultHeightCard,
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Row(children: [
                const Image(
                  image: AssetImage('assets/images/image.png'),
                  height: 45,
                  width: 45,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderList.productName,
                        style: Styles.textStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      changeQuantityButton(context, size, orderList),
                    ],
                  ),
                ),
              ]),
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              orderList.discount <= 0
                  ? Text(
                      Formats.formatNumber((orderList.total).toString()),
                      style: Styles.textStyle,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(Formats.formatNumber((orderList.total).toString()),
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough)),
                        Text(
                          Formats.formatNumber(
                              (orderList.total - orderList.discount)
                                  .toString()),
                          style: Styles.textStyle,
                        ),
                      ],
                    ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                ),
                color: Styles.primaryColor,
                onPressed: () {
                  showTransactionOption(context, size, orderList);
                },
              ),
            ])
          ],
        ),
      ),
    );
  }

  changeQuantityButton(
      BuildContext context, size, CaptainOrderTransaction transaction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
            onTap: () {
              controller.decrease(context, transaction, false);
            },
            child: Icon(
              Icons.remove_circle,
              color: transaction.quantity > 1
                  ? Styles.dangerColor
                  : Styles.disabledColor,
              size: Styles.changeQuantityButtonSize,
            )),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3), color: Colors.white),
          child: Text(
            transaction.quantity.toString(),
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
        InkWell(
            onTap: () {
              controller.increase(context, transaction, false);
            },
            child: Icon(
              Icons.add_circle,
              color: Styles.primaryColor,
              size: Styles.changeQuantityButtonSize,
            )),
      ],
    );
  }

  Future<dynamic> bottomPaymentDetail(context, size) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Obx(
            () => Container(
              padding: const EdgeInsets.all(20),
              width: size.width,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Summary",
                      style: Styles.headLineStyle3,
                    ),
                    const Divider(
                      height: 10,
                      thickness: 1,
                      endIndent: 0,
                      color: Color.fromARGB(255, 226, 226, 226),
                    ),
                    detailTextSummary(
                        context,
                        size,
                        "Sub Total",
                        false,
                        controller.summary["subTotal"].toString(),
                        false,
                        false),
                    detailTextSummary(context, size, "Total Discount", false,
                        controller.summary["discount"].toString(), false, true),
                    detailTextSummary(
                        context,
                        size,
                        "Total (After Discount)",
                        false,
                        controller.summary["afterDiscount"].toString(),
                        true,
                        false),
                    detailTextSummary(context, size, "Total Service", false,
                        controller.summary["service"].toString(), false, false),
                    detailTextSummary(context, size, "Total Tax", false,
                        controller.summary["tax"].toString(), false, false),
                    detailTextSummary(
                        context,
                        size,
                        "Grand Total",
                        false,
                        controller.summary["grandTotal"].toString(),
                        true,
                        false),
                    detailTextSummary(
                        context,
                        size,
                        "Payment",
                        false,
                        controller.summary["totalPayment"].toString(),
                        false,
                        false),
                    detailTextSummary(
                      context,
                      size,
                      num.parse(controller.summary["total"].toString()) < 0
                          ? "Refund"
                          : "Charge",
                      true,
                      num.parse(controller.summary["total"].toString()) < 0
                          ? (-num.parse(controller.summary["total"].toString()))
                              .toString()
                          : controller.summary["total"].toString(),
                      true,
                      false,
                      style:
                          num.parse(controller.summary["total"].toString()) < 0
                              ? Styles.textStyle.copyWith(color: Colors.green)
                              : Styles.textStyle.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all<Size>(
                            Size(size.width / 4, 38)),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                        backgroundColor: WidgetStateProperty.all<Color>(
                            controller.captainOrderTransactionList.isNotEmpty
                                ? Styles.primaryColor
                                : Styles.disabledColor),
                        shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Styles.defaultRadius),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        controller.captainOrderTransactionList.isEmpty
                            ? null
                            : selectPrinterDialogX(context);

                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.print), // Add the print icon
                          SizedBox(
                              width:
                                  8), // Add spacing between the icon and text
                          Text('Captain Order'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<dynamic> selectPrinterDialog(BuildContext context) {
    Navigator.pop(context);
    return showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent the dialog from being dismissed by tapping outside
      builder: (context) {
        return AlertDialog(
          title: Text(printController.isDiscovering.value > 0
              ? 'Searching for Printers'
              : 'Select a Printer'),
          content: FutureBuilder(
            future: printController.discoverPrinters(),
            builder: (context, snapshot) {
              if (printController.isDiscovering.value > 0) {
                // Show loading indicator while discovering printers
                return const SizedBox(
                    height: 100,
                    child: Center(
                      child: SizedBox(
                        height: 30.0,
                        width: 30.0,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ));
              } else if (snapshot.hasError) {
                // Show an error message if discovery fails
                return const Text('Error discovering printers');
              } else {
                if (printController.printers.isEmpty) {
                  return const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text("Printer device not found"),
                      ));
                } else {
                  // Show the printer list once discovery is complete
                  return SingleChildScrollView(
                    child: ListBody(
                      children: printController.printers.map((printerName) {
                        return InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            printController.isPrinting.value = 1;
                            try {
                              printController.captainOrderId = controller.id;
                              await printController.loadPrintCaptainOrderData();
                              final profile = await CapabilityProfile.load();
                              const paper = PaperSize.mm80;
                              final printer = NetworkPrinter(paper, profile);
                              final PosPrintResult res = await printer
                                  .connect(printerName, port: 9100);
                              if (res == PosPrintResult.success) {
                                await Printer.printReceipt(
                                    printer,
                                    printController.captainOrder.value,
                                    printController.company.value,
                                    printController.transaction);
                              } else {
                                print('Print connection failed: ${res.msg}');
                              }
                            } catch (e) {
                              debugPrint('Print error: $e');
                            } finally {
                              printController.isPrinting.value = 0;
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 60,
                                padding: const EdgeInsets.only(left: 10),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: <Widget>[
                                    const Icon(Icons.print),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            '${printerName}:${printController.port}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            'Click to print a receipt',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  BluetoothDevice? _device;
  Future<dynamic> selectPrinterDialogX(BuildContext context) {
    bool isBluetooth =
        false; // Variable to track which type of printer is selected (Wi-Fi or Bluetooth)

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: ValueListenableBuilder<bool>(
            valueListenable: ValueNotifier(isBluetooth),
            builder: (context, isBluetooth, child) {
              return const Text('Select a Printer');
            },
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height *
                        0.6, // Set maximum height
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Toggle button to switch between Wi-Fi and Bluetooth printers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isBluetooth = false;
                              });
                            },
                            child: Text('Wi-Fi'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isBluetooth = true;
                                controller.initBluetooth();
                              });
                            },
                            child: Text('Bluetooth'),
                          ),
                        ],
                      ),
                      Divider(),

                      // Show Wi-Fi or Bluetooth printers based on the current selection
                      if (!isBluetooth)
                        // Wi-Fi printer discovery
                        FutureBuilder(
                          future: printController.discoverPrinters(),
                          builder: (context, snapshot) {
                            if (printController.isDiscovering.value > 0) {
                              return const SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Text('Error discovering printers');
                            } else {
                              if (printController.printers.isEmpty) {
                                return const Text("Printer device not found");
                              } else {
                                return SingleChildScrollView(
                                  child: Column(
                                    children: printController.printers
                                        .map((printerName) {
                                      return ListTile(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          printController.isPrinting.value = 1;
                                          try {
                                            printController.captainOrderId =
                                                controller.id;
                                            await printController
                                                .loadPrintCaptainOrderData();
                                            final profile =
                                                await CapabilityProfile.load();
                                            const paper = PaperSize.mm80;
                                            final printer =
                                                NetworkPrinter(paper, profile);
                                            final PosPrintResult res =
                                                await printer.connect(
                                                    printerName,
                                                    port: 9100);
                                            if (res == PosPrintResult.success) {
                                              await Printer.printReceipt(
                                                  printer,
                                                  printController
                                                      .captainOrder.value,
                                                  printController.company.value,
                                                  printController.transaction);
                                            } else {
                                              print(
                                                  'Print connection failed: ${res.msg}');
                                            }
                                          } catch (e) {
                                            debugPrint('Print error: $e');
                                          } finally {
                                            printController.isPrinting.value =
                                                0;
                                          }
                                        },
                                        title: Text(printerName),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }
                            }
                          },
                        )
                      else
                        // Bluetooth printer discovery
                        RefreshIndicator(
                          onRefresh: () => controller.bluetoothPrint
                              .startScan(timeout: Duration(seconds: 4)),
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Text(controller.tips.value),
                                Divider(),
                                SizedBox(
                                  height: 300, // Adjust the height as needed
                                  child: SingleChildScrollView(
                                    child: StreamBuilder<List<BluetoothDevice>>(
                                      stream:
                                          controller.bluetoothPrint.scanResults,
                                      initialData: [],
                                      builder: (context, snapshot) {
                                        return Column(
                                          children: snapshot.data!.map((d) {
                                            return ListTile(
                                              title: Text(d.name ?? ''),
                                              subtitle: Text(d.address ?? ''),
                                              onTap: () async {
                                                setState(() {
                                                  _device = d;
                                                });
                                              },
                                              trailing: _device != null &&
                                                      _device!.address ==
                                                          d.address
                                                  ? Icon(Icons.check,
                                                      color: Colors.green)
                                                  : null,
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                Divider(),
                                // Connect/Disconnect Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    OutlinedButton(
                                      child: Text('Print'),
                                      onPressed: controller.connected.value
                                          ? () async {
                                              setState(() {
                                                controller.tips.value =
                                                    'Printing...';
                                              });

                                              Navigator.pop(context);
                                              printController.isPrinting.value =
                                                  1;
                                              try {
                                                printController.captainOrderId =
                                                    controller.id;
                                                await printController
                                                    .loadPrintCaptainOrderData();

                                                await Printer
                                                    .printReceiptBluetooth(
                                                        controller
                                                            .bluetoothPrint,
                                                        printController
                                                            .captainOrder.value,
                                                        printController
                                                            .company.value,
                                                        printController
                                                            .transaction,
                                                        printController
                                                            .payment);
                                              } catch (e) {
                                                debugPrint('Print error: $e');
                                              } finally {
                                                controller.tips.value =
                                                    'Please select a device';
                                                printController
                                                    .isPrinting.value = 0;
                                              }
                                            }
                                          : null,
                                    ),
                                    SizedBox(width: 10),
                                    OutlinedButton(
                                      child: Text('Connect'),
                                      onPressed: controller.connected.value
                                          ? null
                                          : () async {
                                              if (_device != null &&
                                                  _device!.address != null) {
                                                setState(() {
                                                  controller.tips.value =
                                                      'Connecting...';
                                                });
                                                final res = await controller
                                                    .bluetoothPrint
                                                    .connect(_device!);
                                                // controller.isLoadingIndicator
                                                //     .value = true;
                                                Future.delayed(
                                                    Duration(seconds: 5), () {
                                                  controller.initBluetooth();
                                                  // controller.isLoadingIndicator
                                                  //     .value = false;
                                                });
                                                // if (res) {
                                                //   controller.bluetoothPrint
                                                //       .printTest();
                                                // }
                                              } else {
                                                setState(() {
                                                  controller.tips.value =
                                                      'Please select a device';
                                                });
                                              }
                                            },
                                    ),
                                    SizedBox(width: 10),
                                    OutlinedButton(
                                      child: Text('Disconnect'),
                                      onPressed: controller.connected.value
                                          ? () async {
                                              setState(() {
                                                controller.tips.value =
                                                    'Disconnecting...';
                                              });
                                              await controller.bluetoothPrint
                                                  .disconnect();

                                              // controller.isLoadingIndicator.value =
                                              //     true;
                                              Future.delayed(
                                                  Duration(seconds: 5), () {
                                                controller.initBluetooth();
                                                // controller.isLoadingIndicator
                                                //     .value = false;
                                              });
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Column detailTextSummary(context, size, String label, bool labelBold,
      String value, bool divider, bool editable,
      {TextStyle? style}) {
    return Column(
      children: [
        divider
            ? const Divider(
                height: 10,
                thickness: 1,
                endIndent: 0,
                color: Color.fromARGB(255, 226, 226, 226))
            : const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: style ??
                    (labelBold ? Styles.headLineStyle4 : Styles.textStyle)),
            editable
                ? InkWell(
                    onTap: () {
                      controller.captainOrderTransactionList.isNotEmpty
                          ? showModalAccess(
                              context,
                              null,
                              controller.specialAccessController
                                  .userSpecialAccess.discount)
                          : null;
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mode_edit_outlined,
                          size: 18,
                        ),
                        const SizedBox(height: 5),
                        Text(Formats.formatNumber(value),
                            style: labelBold
                                ? Styles.headLineStyle4
                                : Styles.textStyle)
                      ],
                    ))
                : Text(Formats.formatNumber(value),
                    style:
                        labelBold ? Styles.headLineStyle4 : Styles.textStyle),
          ],
        ),
      ],
    );
  }

  showTransactionOption(
      BuildContext context, size, CaptainOrderTransaction transaction) async {
    if (controller.isLoadingIndicator.value) return;
    await controller.getIsCaptainOrderStatusOpen(context);
    if (!controller.isCaptainOrderStatusOpen.value) {
      return controller.showAlertCOClosed(context);
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  10.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.all(
              10.0,
            ),
            title: Text(
              "${transaction.description}",
              style: Styles.headLineStyle2,
            ),
            content: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showModalAccess(
                            context,
                            transaction,
                            controller.specialAccessController.userSpecialAccess
                                .removeItem);
                      },
                      child: optionButton(context, "Remove",
                          icon: const Icon(Icons.delete_outline))),
                  InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        controller.discountType.value = 1;
                        showModalAccess(
                            context,
                            transaction,
                            controller.specialAccessController.userSpecialAccess
                                .discount);
                      },
                      child: optionButton(context, "Discount",
                          icon: const Icon(Icons.discount_outlined))),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showModalAccess(
                            context,
                            transaction,
                            controller.specialAccessController.userSpecialAccess
                                .overridePrice);
                      },
                      child: optionButton(context, "Override Price",
                          icon: const Icon(Icons.price_change_outlined))),
                ],
              ),
            ),
          );
        });
  }

  Container optionButton(BuildContext context, String text,
      {Future? onPressed, required Icon icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          icon,
          const SizedBox(height: 5),
          Text(text),
        ],
      ),
    );
  }

  Future<void> showModalBottomOverride(
      context, CaptainOrderTransaction transaction) {
    controller.oldPriceController.text = transaction.priceOriginal.toString();
    return showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        const Icon(Icons.price_change_outlined),
                        const SizedBox(height: 5),
                        Text(
                          "Override Price",
                          style: Styles.headLineStyle3,
                        ),
                      ],
                    ),
                    const Divider(),
                    TextFormField(
                      textAlign: TextAlign.end,
                      controller: controller.oldPriceController,
                      textInputAction: TextInputAction.next,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: "0,00",
                        labelText: "Current Price",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 33, 28, 28),
                              width: 2.0),
                          borderRadius:
                              BorderRadius.circular(Styles.defaultRadius),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 33, 28, 28),
                              width: 2.0),
                          borderRadius:
                              BorderRadius.circular(Styles.defaultRadius),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      autofocus: true,
                      textAlign: TextAlign.end,
                      controller: controller.newPriceController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (value) {
                        controller.overridePrice(context, transaction.iDLog);
                        Navigator.pop(context);
                      },
                      decoration: InputDecoration(
                        hintText: "0,00",
                        labelText: "New Price",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 33, 28, 28),
                              width: 2.0),
                          borderRadius:
                              BorderRadius.circular(Styles.defaultRadius),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 33, 28, 28),
                              width: 2.0),
                          borderRadius:
                              BorderRadius.circular(Styles.defaultRadius),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Field is required';
                        }
                        return controller.floatValidation(value);
                      },
                    ),
                    const Divider(),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all<Size>(
                                    Size(double.infinity,
                                        Styles.defaultHeightButton)),
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(
                                        Styles.primaryColor),
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Styles.defaultRadius)))),
                            child: const Text('Save'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                controller.overridePrice(
                                    context, transaction.iDLog);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showModalBottomDiscount(context, transactionId) {
    controller.discountType.value = transactionId == null ? 3 : 1;
    controller.isPercent.value =
        controller.discountType.value == 3 ? false : true;
    print("2 $context");

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
                          const Icon(Icons.discount_outlined),
                          const SizedBox(height: 5),
                          Text(
                            "Discount",
                            style: Styles.headLineStyle3,
                          ),
                        ],
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Styles.defaultRadius),
                            border: Border.all(
                                color: const Color.fromARGB(255, 33, 28, 28))),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: FlutterSwitch(
                                // height: 20.0,
                                // width: 40.0,
                                activeIcon: const Icon(Icons.percent_outlined),
                                inactiveIcon:
                                    const Icon(Icons.numbers_outlined),
                                toggleSize: 25.0,
                                borderRadius: Styles.defaultRadius,
                                activeColor: Styles.primaryColor,
                                value: controller.isPercent.value,
                                onToggle: (value) {
                                  if (controller.discountType.value == 3)
                                    return;
                                  controller.discountController.clear();
                                  controller.isPercent.value = value;
                                },
                              ),
                            ),
                            Form(
                              key: _formKey,
                              child: Flexible(
                                  child: TextFormField(
                                autofocus: true,
                                onFieldSubmitted: (value) {
                                  if (_formKey.currentState!.validate()) {
                                    controller.discount(context, transactionId);
                                    Navigator.pop(context);
                                  }
                                },
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                controller: controller.discountController,
                                decoration: InputDecoration(
                                  hintText:
                                      controller.isPercent.value ? "%" : "0.00",
                                  // labelText: "Discount",
                                  filled: true,
                                  border: InputBorder.none,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Field is required';
                                  }
                                  if (controller.isPercent.value &&
                                      (controller.parseAmount(value) ?? 0) >
                                          100) {
                                    return 'Cannot discount more than 100%';
                                  }
                                  return controller.floatValidation(value);
                                },
                              )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all<Size>(
                                      Size(double.infinity,
                                          Styles.defaultHeightButton)),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Styles.primaryColor),
                                  shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              Styles.defaultRadius)))),
                              child: const Text('Save'),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await controller.discount(
                                      context, transactionId);
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(true);
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> showModalAccess(context, transaction, accessMode) {
    controller.userController.text = "";
    controller.passwordController.text = "";
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
                          const SizedBox(height: 5),
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
                            key: _formKeyUserAccess,
                            child: Flexible(
                                child: Column(
                              children: [
                                TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  autofocus: true,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [UpperCaseTextFormatter()],
                                  style: Styles.textStyle,
                                  controller: controller.userController,
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
                                const SizedBox(height: 5),
                                TextFormField(
                                    style: Styles.textStyle,
                                    textInputAction: TextInputAction.next,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    obscureText: controller.hidePassword.value,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    controller: controller.passwordController,
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
                                              controller.hidePassword.value =
                                                  !controller
                                                      .hidePassword.value;
                                            },
                                            onTapUp: (detail) {
                                              controller.hidePassword.value =
                                                  !controller
                                                      .hidePassword.value;
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
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKeyUserAccess.currentState!
                                        .validate()) {
                                      await _saveSpecialAccess(
                                          context, transaction, accessMode);
                                    }
                                  },
                                  style: ButtonStyle(
                                      minimumSize:
                                          WidgetStateProperty.all<Size>(Size(
                                              double.infinity,
                                              Styles.defaultHeightButton)),
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
                                  controller.accessStatus.value,
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

  inputText(
      controller, value, validator, label, hint, enabled, bool autofocus) {
    controller.text = value;
    return TextFormField(
      autofocus: autofocus,
      textAlign: TextAlign.end,
      controller: controller,
      textInputAction: TextInputAction.next,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(10),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 33, 28, 28), width: 2.0),
          borderRadius: BorderRadius.circular(Styles.defaultRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 33, 28, 28), width: 2.0),
          borderRadius: BorderRadius.circular(Styles.defaultRadius),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        if (validator != null) {
          return validator(value);
        }

        return null;
      },
    );
  }
}
