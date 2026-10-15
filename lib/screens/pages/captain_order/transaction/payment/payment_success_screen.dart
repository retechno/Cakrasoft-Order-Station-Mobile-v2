import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:point_of_sales/screens/pages/print_receipt/print_receipt_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/printer.dart';

import '../captain_order_transaction_controller.dart';

class PaymentSuccessfulScreen extends GetView<PrintReceiptController> {
  final PrintReceiptController printController =
      Get.put(PrintReceiptController());

  final CaptainOrderTransactionController captainOrderController =
      Get.put(CaptainOrderTransactionController());
  final String totalChange;
  final String checkNumber;
  PaymentSuccessfulScreen(
      {Key? key, required this.checkNumber, required this.totalChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    Get.put(PrintReceiptController());

    return WillPopScope(
        onWillPop: () async {
          // Disable back navigation by returning false
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Obx(
            () => ModalProgressHUD(
              inAsyncCall: printController.isPrinting.value > 0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 90,
                      color: Styles.primaryColor,
                    ),
                    SizedBox(height: 10),
                    Text("Transaction Success!", style: Styles.headLineStyle),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 20,
                      width: size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Refund",
                            style: Styles.headLineStyle2,
                          ),
                          Text(
                              style: Styles.headLineStyle2,
                              Formats.formatNumber(totalChange).toString())
                        ],
                      ),
                    ),
                    const Divider(
                        height: 10,
                        thickness: 1,
                        endIndent: 0,
                        color: Color.fromARGB(255, 226, 226, 226)),
                    SizedBox(
                      height: Styles.defaultHeightButton,
                      width: size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: () async {
                          selectPrinterDialogX(context);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors
                              .white), // Set the background color to transparent
                          foregroundColor: WidgetStateProperty.all<Color>(
                              Styles.textColor),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Styles.defaultRadius),
                              side: BorderSide(
                                  color: Styles
                                      .primaryColor), // Add the border with primary color
                            ),
                          ),
                        ),
                        child: const Text(
                          "Print Receipt",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // A gap to separate buttons
                    SizedBox(
                      height: Styles.defaultHeightButton,
                      width: size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: () {
                          // Perform action for "Preview Receipt"
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors
                              .white), // Set the background color to transparent
                          foregroundColor: WidgetStateProperty.all<Color>(
                              Styles.textColor),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Styles.defaultRadius),
                              side: BorderSide(
                                  color: Styles
                                      .primaryColor), // Add the border with primary color
                            ),
                          ),
                        ),
                        child: const Text(
                          "Preview Receipt",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // A gap to separate buttons
                    SizedBox(
                      height: Styles.defaultHeightButton,
                      width: size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: () {
                          // Perform action for "New Order"
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Styles.primaryColor),
                          foregroundColor: WidgetStateProperty.all<Color>(
                              Styles.textColorButton),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Styles.defaultRadius),
                            ),
                          ),
                        ),
                        child: const Text(
                          "New Order",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Future<dynamic> selectPrinterDialog(BuildContext context) {
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
                            printingWifi(printerName, context);
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
        false; // Track which type of printer is selected (Wi-Fi or Bluetooth)

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
                                captainOrderController.initBluetooth();
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
                                return Column(
                                  children: printController.printers
                                      .map((printerName) {
                                    return ListTile(
                                      onTap: () async {
                                        printingWifi(printerName, context);
                                      },
                                      title: Text(printerName),
                                    );
                                  }).toList(),
                                );
                              }
                            }
                          },
                        )
                      else
                        // Bluetooth printer discovery
                        RefreshIndicator(
                          onRefresh: () => captainOrderController.bluetoothPrint
                              .startScan(timeout: Duration(seconds: 4)),
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Text(captainOrderController.tips.value),
                                Divider(),
                                SizedBox(
                                  height: 300, //
                                  child: SingleChildScrollView(
                                    child: StreamBuilder<List<BluetoothDevice>>(
                                      stream: captainOrderController
                                          .bluetoothPrint.scanResults,
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
                                      onPressed: captainOrderController
                                              .connected.value
                                          ? () async {
                                              setState(() {
                                                captainOrderController
                                                    .tips.value = 'Printing...';
                                              });
                                              Navigator.pop(context);
                                              printController.isPrinting.value =
                                                  1;
                                              try {
                                                await printController
                                                    .loadPrintCheckData(
                                                        checkNumber);
                                                await Printer
                                                    .printCheckBluetooth(
                                                        captainOrderController
                                                            .bluetoothPrint,
                                                        printController
                                                            .check.value,
                                                        printController
                                                            .company.value,
                                                        printController
                                                            .checkTransaction,
                                                        printController
                                                            .checkPayment);
                                              } catch (e) {
                                                debugPrint('Print error: $e');
                                              } finally {
                                                captainOrderController
                                                        .tips.value =
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
                                      onPressed: captainOrderController
                                              .connected.value
                                          ? null
                                          : () async {
                                              if (_device != null &&
                                                  _device!.address != null) {
                                                setState(() {
                                                  captainOrderController.tips
                                                      .value = 'Connecting...';
                                                });
                                                final res =
                                                    await captainOrderController
                                                        .bluetoothPrint
                                                        .connect(_device!);
                                                Future.delayed(
                                                    Duration(seconds: 5), () {
                                                  captainOrderController
                                                      .initBluetooth();
                                                });
                                              } else {
                                                setState(() {
                                                  captainOrderController
                                                          .tips.value =
                                                      'Please select a device';
                                                });
                                              }
                                            },
                                    ),
                                    SizedBox(width: 10),
                                    OutlinedButton(
                                      child: Text('Disconnect'),
                                      onPressed: captainOrderController
                                              .connected.value
                                          ? () async {
                                              setState(() {
                                                captainOrderController.tips
                                                    .value = 'Disconnecting...';
                                              });
                                              await captainOrderController
                                                  .bluetoothPrint
                                                  .disconnect();
                                              Future.delayed(
                                                  Duration(seconds: 5), () {
                                                captainOrderController
                                                    .initBluetooth();
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

  Future<void> printingWifi(String printerName, BuildContext context) async {
    Navigator.pop(context);
    printController.isPrinting.value = 1;
    try {
      await printController.loadPrintCheckData(checkNumber);
      final profile = await CapabilityProfile.load();
      const paper = PaperSize.mm80;
      final printer = NetworkPrinter(paper, profile);
      final PosPrintResult res = await printer.connect(printerName, port: 9100);
      if (res == PosPrintResult.success) {
        await Printer.printCheck(printer, printController.check.value,
            printController.company.value, printController.checkTransaction);
      } else {
        print('Print connection failed: ${res.msg}');
      }
    } catch (e) {
      debugPrint('Print error: $e');
    } finally {
      printController.isPrinting.value = 0;
    }
  }
}
