// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/payment_data.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/payment_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment_method/payment_method_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/widget/numpad_widget.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';

class CashPaymentScreen extends GetView<PaymentController> {
  final PaymentData paymentData;

  final PaymentMethodController paymentMethodController =
      Get.find<PaymentMethodController>();
  final CaptainOrderTransactionController captainOrderTransactionController =
      Get.find<CaptainOrderTransactionController>();
  final PaymentController paymentController = Get.find<PaymentController>();

  CashPaymentScreen({Key? key, required this.paymentData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final TextEditingController myController = TextEditingController();
    return Scaffold(
        backgroundColor: Styles.bgColor,
        body: Column(
          children: [
            Container(
                padding: Styles.paddingBody * 2,
                child: Column(
                  children: [
                    TitleHeaderWidget(context,
                        title: controller.accountName.value),
                    Text(
                      "Amount",
                      style: Styles.headLineStyle,
                    ),
                    SizedBox(
                      height: 65,
                      // color: Colors.white,
                      child: Center(
                        child: Column(
                          children: [
                            TextField(
                              showCursor: false,
                              style: const TextStyle(fontSize: 30),
                              textAlign: TextAlign.center,
                              controller: myController,
                              inputFormatters: [
                                CurrencyTextInputFormatter.currency(
                                  locale: 'id_ID',
                                  decimalDigits: 0,
                                )
                              ],
                              keyboardType: TextInputType.none,
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(fontSize: 24),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                filled: true,
                                contentPadding: const EdgeInsets.all(10),
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Charge",
                          style: Styles.headLineStyle3,
                        ),
                        Text(
                          Formats.formatNumber(num.parse(
                                      controller.summary["total"].toString()) >
                                  0
                              ? controller.summary["total"]
                              : 0),
                          style: Styles.headLineStyle3,
                        )
                      ],
                    )
                  ],
                )),
            Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: Styles.paddingBody,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                      ),
                      child: NumPadWidget(
                        buttonSize: 85,
                        buttonColor: Styles.bgColor,
                        iconColor: Styles.primaryColor,
                        controller: myController,
                        delete: () {
                          if (myController.text.isNotEmpty) {
                            myController.text = Formats.formatCurrency(
                                myController.text.substring(
                                    0, myController.text.length - 1));
                          }
                        },
                        onSubmit: () {
                          if (myController.text.isNotEmpty) {
                            paymentController.confirmPayment(
                                context,
                                num.parse(Formats.currencyToNumber(
                                    myController.text)),
                                paymentData);
                          }
                        },
                      ),
                    ))),
          ],
        ));
  }
}
