import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/city_ledger/city_ledger_payment_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/payment_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment_method/payment_method_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/widget/numpad_widget.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';

class CityLedgerPaymentScreen extends GetView<CityLedgerPaymentController> {
  @override
  final controller = Get.put(CityLedgerPaymentController());

  final PaymentMethodController paymentMethodController =
      Get.find<PaymentMethodController>();
  final CaptainOrderTransactionController captainOrderTransactionController =
      Get.find<CaptainOrderTransactionController>();
  final PaymentController paymentController = Get.find<PaymentController>();

  CityLedgerPaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Styles.bgColor,
        body: Column(
          children: [
            Container(
              padding: Styles.paddingBody * 2,
              child: Column(
                children: [
                  TitleHeaderWidget(context,
                      title: controller.paymentController.accountName.value),
                  Text("Amount", style: Styles.headLineStyle),
                  SizedBox(
                    height: 65,
                    child: Center(
                      child: Column(
                        children: [
                          TextField(
                            showCursor: false,
                            style: const TextStyle(fontSize: 30),
                            textAlign: TextAlign.center,
                            controller: controller.amountController,
                            inputFormatters: [
                              CurrencyTextInputFormatter.currency(
                                locale: 'id_ID',
                                decimalDigits: 0,
                              ),
                            ],
                            keyboardType: TextInputType.none,
                            decoration: InputDecoration(
                                // ... Your decoration properties ...
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
                                    captainOrderTransactionController
                                        .summary["total"]
                                        .toString()) >
                                0
                            ? captainOrderTransactionController.summary["total"]
                            : 0),
                        style: Styles.headLineStyle3,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  const Divider(
                      height: 10,
                      thickness: 1,
                      endIndent: 0,
                      color: Color.fromARGB(255, 226, 226, 226)),
                  dropdownInputFormTable(
                      controller.company, controller.companies, "Company*"),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: Styles.paddingBody,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: NumPadWidget(
                    buttonSize: 85,
                    buttonColor: Styles.bgColor,
                    iconColor: Styles.primaryColor,
                    controller: controller.amountController,
                    delete: () {
                      if (controller.amountController.text.isNotEmpty) {
                        controller.amountController.text =
                            Formats.formatCurrency(
                          controller.amountController.text.substring(
                              0, controller.amountController.text.length - 1),
                        );
                      }
                    },
                    onSubmit: () {
                      if (controller.amountController.text.isNotEmpty) {
                        controller.processPayment(context);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column dropdownInputFormTable(dynamic dropdownValue, List items, label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField(
            isExpanded: true,
            decoration: InputDecoration(
                labelText: label,
                enabled: false,
                labelStyle: Styles.textStyle,
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0)),
            initialValue: dropdownValue?.value,
            onChanged: (newValue) {
              dropdownValue?.value = newValue!;
            },
            items: items.map((map) {
              return DropdownMenuItem<String>(
                value: map.code,
                child: Text(map.name,
                    style: const TextStyle(height: 0.0, fontSize: 12)),
              );
            }).toList()),
      ],
    );
  }
}
