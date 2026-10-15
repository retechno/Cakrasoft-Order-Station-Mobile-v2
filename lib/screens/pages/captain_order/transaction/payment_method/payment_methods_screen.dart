import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/payment_data.dart';
import 'package:point_of_sales/models/payment_method.dart';

import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/cash/cash_payment_screen.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/city_ledger/city_ledger_payment_screen.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/edc/edc_payment_screen.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/payment_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/transfer_folio/transfer_folio_screen.dart';

import 'package:point_of_sales/screens/pages/captain_order/transaction/payment_method/payment_method_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/mutation_guard.dart';
import 'package:point_of_sales/widget/skeleton_list_widget.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';

import '../../../../../utils/app_utils.dart';

class PaymentMethodsScreen extends GetView<PaymentMethodController> {
  PaymentMethodsScreen({Key? key}) : super(key: key);
  final CaptainOrderTransactionController captainOrderTransactionController =
      Get.put(CaptainOrderTransactionController());

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    return Obx(
      () => Scaffold(
        backgroundColor: Styles.bgColor,
        body: Container(
          padding: Styles.paddingBody,
          child: Column(
            children: [
              TitleHeaderWidget(
                context,
                title: "Payment Methods",
                titleDetail: "CO #${controller.coNumber}",
              ),
              Expanded(
                child: controller.isLoading.value
                    ? ItemListSkeleton(
                        itemCount: 5,
                        itemHeight: Styles.defaultHeightCard,
                        itemPadding: EdgeInsets.symmetric(
                            horizontal: 1, vertical: Styles.defaultPadding / 2),
                        listPadding: EdgeInsets.only(
                            top: Styles.defaultPadding,
                            bottom: Styles.defaultPadding,
                            left: 5,
                            right: 5),
                        isHorizontal: false,
                      )
                    : controller.paymentMethodList.isNotEmpty
                        ? ListView(
                            children: List.generate(
                                controller.paymentMethodList.length, (index) {
                              return paymentMethodList(context,
                                  controller.paymentMethodList[index], 0);
                            }),
                          )
                        : const Center(
                            child: Text("No data found"),
                          ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, bottom: 0, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          num.parse(captainOrderTransactionController
                                      .summary["total"]
                                      .toString()) <
                                  0
                              ? "Refund"
                              : "Total",
                          style: Styles.headLineStyle4,
                        ),
                        InkWell(
                          onTap: () {
                            captainOrderTransactionController.totalPrices();
                            bottomPaymentDetail(context, size);
                          },
                          child: Row(
                            children: [
                              Text(
                                Formats.formatNumber(
                                  num.parse(captainOrderTransactionController
                                              .summary["total"]
                                              .toString()) <
                                          0
                                      ? (-num.parse(
                                              captainOrderTransactionController
                                                  .summary["total"]
                                                  .toString()))
                                          .toString()
                                      : captainOrderTransactionController
                                          .summary["total"]
                                          .toString(),
                                ),
                                style: Styles.textStyle,
                              ),
                              const Icon(Icons.expand_less)
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      ElevatedButton(
                        onPressed: () {
                          showConfirmDialog(context);
                        },
                        style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all<Size>(
                                Size(size.width / 3, 38)),
                            foregroundColor:
                                WidgetStateProperty.all<Color>(Colors.white),
                            backgroundColor: WidgetStateProperty.all<Color>(
                                controller.totalPayment() >=
                                        captainOrderTransactionController
                                            .totalTransactionPrice.value
                                    ? Styles.primaryColor
                                    : Styles.disabledColor),
                            shape: WidgetStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Styles.defaultRadius),
                            ))),
                        child: const Text("Finish Sale"),
                      )
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Function to show the confirm dialog
  void showConfirmDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure ?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context, false); // Dismiss the dialog, return false
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Dismiss the dialog, return true
              },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Styles.primaryColor),
              ),
              child: Text("Confirm"),
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

  paymentMethodList(context, PaymentMethod paymentMethod, amount) {
    return InkWell(
      onTap: () {
        onClickPaymentMethod(context, paymentMethod);
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/cash.svg",
                    width: 40,
                  ),
                  SizedBox(height: 5),
                  Text(
                    paymentMethod.name.toString(),
                    style: Styles.textStyle,
                  )
                ],
              ),
              Row(
                children: [
                  controller.getDisplayAmount(paymentMethod),
                  const Icon(Icons.chevron_right)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onClickPaymentMethod(context, PaymentMethod paymentMethod) async {
    await MutationGuard.run('openPaymentMethod',
        () => _openPaymentMethod(context, paymentMethod));
  }

  Future<void> _openPaymentMethod(
      context, PaymentMethod paymentMethod) async {
    PaymentController paymentController = Get.put(PaymentController());
    paymentController.accountCode.value = paymentMethod.accountCode;
    paymentController.accountName.value = paymentMethod.name;
    paymentController.paymentMethod.value = paymentMethod;
    await controller.getPaymentStatus(context, paymentMethod.accountCode);
    print(controller.canPayment.value);
    if (!controller.canPayment.value) {
      return;
    }
    switch (paymentMethod.subGroupCode) {
      case "PYMT":
        Get.to(() => CashPaymentScreen(
              paymentData: PaymentData(
                  captainOrderId: captainOrderTransactionController.id.value,
                  accountCode: paymentMethod.accountCode,
                  accountName: paymentMethod.name,
                  paymentAmount: 0),
            ));
        break;
      case "CRDB":
        Get.to(() => EDCPaymentScreen());
        break;
      case "BKTR":
        // Get.to(() => EDCPaymentScreen());
        Get.to(() => CashPaymentScreen(
              paymentData: PaymentData(
                  captainOrderId: captainOrderTransactionController.id.value,
                  accountName: paymentMethod.name,
                  accountCode: paymentMethod.accountCode,
                  paymentAmount: 0),
            ));
        // Add code to navigate to the Bank Transfer payment screen
        break;
      case "CMPL":
        // Add code to navigate to the Compliment payment screen
        Get.to(() => CityLedgerPaymentScreen());
        break;
      case "ACRV":
        Get.to(() => CityLedgerPaymentScreen());
        // Add code to navigate to the Account Receivable payment screen
        break;
      case "OTPY":
        Get.to(() => CashPaymentScreen(
              paymentData: PaymentData(
                  captainOrderId: captainOrderTransactionController.id.value,
                  accountCode: paymentMethod.accountCode,
                  accountName: paymentMethod.name,
                  paymentAmount: 0),
            ));
        // Add code to navigate to the Other Payment screen
        break;
      case "TRAN":
        Get.to(() => TransferToFolioScreen());
        // Add code to navigate to the Transfer payment screen
        break;
      case "DSCN":
        Get.to(() => CashPaymentScreen(
              paymentData: PaymentData(
                  captainOrderId: captainOrderTransactionController.id.value,
                  accountCode: paymentMethod.accountCode,
                  accountName: paymentMethod.name,
                  paymentAmount: 0),
            ));
        // Add code to navigate to the Discount payment screen
        break;
      default:
        // Add code for the case when the subGroupCode does not match any of the above cases
        break;
    }
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
                        captainOrderTransactionController.summary["subTotal"]
                            .toString(),
                        false,
                        false),
                    detailTextSummary(
                        context,
                        size,
                        "Total Discount",
                        false,
                        captainOrderTransactionController.summary["discount"]
                            .toString(),
                        false,
                        true),
                    detailTextSummary(
                        context,
                        size,
                        "Total (After Discount)",
                        false,
                        captainOrderTransactionController
                            .summary["afterDiscount"]
                            .toString(),
                        true,
                        false),
                    detailTextSummary(
                        context,
                        size,
                        "Total Service",
                        false,
                        captainOrderTransactionController.summary["service"]
                            .toString(),
                        false,
                        false),
                    detailTextSummary(
                        context,
                        size,
                        "Total Tax",
                        false,
                        captainOrderTransactionController.summary["tax"]
                            .toString(),
                        false,
                        false),
                    detailTextSummary(
                        context,
                        size,
                        "Grand Total",
                        false,
                        captainOrderTransactionController.summary["grandTotal"]
                            .toString(),
                        true,
                        false),
                    detailTextSummary(
                        context,
                        size,
                        "Payment",
                        false,
                        captainOrderTransactionController
                            .summary["totalPayment"]
                            .toString(),
                        false,
                        false),
                    detailTextSummary(
                      context,
                      size,
                      num.parse(captainOrderTransactionController
                                  .summary["total"]
                                  .toString()) <
                              0
                          ? "Refund"
                          : "Charge",
                      true,
                      num.parse(captainOrderTransactionController
                                  .summary["total"]
                                  .toString()) <
                              0
                          ? (-num.parse(captainOrderTransactionController
                                  .summary["total"]
                                  .toString()))
                              .toString()
                          : captainOrderTransactionController.summary["total"]
                              .toString(),
                      true,
                      false,
                      style: num.parse(captainOrderTransactionController
                                  .summary["total"]
                                  .toString()) <
                              0
                          ? Styles.textStyle.copyWith(color: Colors.green)
                          : Styles.textStyle.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 15),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.print), // Add the print icon
                        SizedBox(
                            width: 8), // Add spacing between the icon and text
                        Text('Captain Order'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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
                      // controller.captainOrderTransactionList.isNotEmpty
                      //     ? showModalAccess(
                      //         context,
                      //         null,
                      //         controller.specialAccessController
                      //             .userSpecialAccess.discount)
                      //     : null;
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
}
