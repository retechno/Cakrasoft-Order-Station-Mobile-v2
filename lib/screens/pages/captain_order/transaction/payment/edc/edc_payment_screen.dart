import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/code_name.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/edc/edc_payment_controller.dart';
import 'package:point_of_sales/utils/app_layout.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:point_of_sales/widget/title_header_widget.dart';

class EDCPaymentScreen extends StatelessWidget {
  final EDCPaymentController controller = Get.put(EDCPaymentController());

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  TitleHeaderWidget(context,
                      title: controller.paymentController.accountName.value),
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
                            showCursor: true,
                            autofocus: true,
                            focusNode: controller.amountFocusNode,
                            style: const TextStyle(fontSize: 30),
                            textAlign: TextAlign.center,
                            controller: controller.amountController,
                            onChanged: (value) {
                              controller.calculateTotal();
                            },
                            inputFormatters: [
                              CurrencyTextInputFormatter.currency(
                                locale: 'id_ID',
                                decimalDigits: 0,
                              )
                            ],
                            keyboardType: TextInputType.number,
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
                        Formats.formatNumber(num.parse(controller
                                    .captainOrderTransactionController
                                    .summary["total"]
                                    .toString()) >
                                0
                            ? controller.captainOrderTransactionController
                                .summary["total"]
                            : 0),
                        style: Styles.headLineStyle3,
                      )
                    ],
                  )
                ],
              ),
              const Divider(
                  height: 10,
                  thickness: 1,
                  endIndent: 0,
                  color: Color.fromARGB(255, 226, 226, 226)),
              SizedBox(height: 16),
              Text(
                "Credit/Debit Card Information",
                style: Styles.headLineStyle3,
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<CodeName>(
                      initialValue: controller.bankCards
                              .contains(controller.selectedBankCard.value)
                          ? controller.selectedBankCard.value
                          : null,
                      onChanged: (CodeName? newValue) {
                        controller.selectedBankCard.value = newValue!;
                      },
                      items: controller.bankCards.isEmpty
                          ? [] // Empty list, provide an empty list of DropdownMenuItem
                          : controller.bankCards
                              .map<DropdownMenuItem<CodeName>>(
                                  (CodeName value) {
                              return DropdownMenuItem<CodeName>(
                                value: value,
                                child: Text(value.name),
                              );
                            }).toList(),
                      decoration: InputDecoration(labelText: 'Bank Card*'),
                    )),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<CodeName>(
                      initialValue: controller.cardTypes
                              .contains(controller.selectedCardType.value)
                          ? controller.selectedCardType.value
                          : null,
                      onChanged: (CodeName? newValue) {
                        controller.selectedCardType.value = newValue!;
                      },
                      items: controller.cardTypes.isEmpty
                          ? [] // Empty list, provide an empty list of DropdownMenuItem
                          : controller.cardTypes
                              .map<DropdownMenuItem<CodeName>>(
                                  (CodeName value) {
                              return DropdownMenuItem<CodeName>(
                                value: value,
                                child: Text(value.name),
                              );
                            }).toList(),
                      decoration: InputDecoration(labelText: 'Card Type*'),
                    )),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: controller.cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Card Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the card number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text("Expire Date"),
              FractionallySizedBox(
                widthFactor: 0.4,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.expiryMonthController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ExpiryMonthFormatter(),
                        ],
                        decoration: InputDecoration(labelText: 'MM'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the expiry month';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controller.expiryYearController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ExpiryYearFormatter(),
                        ],
                        decoration: InputDecoration(labelText: 'YY'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the expiry year';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: controller.chargeInPercentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Charge (%)'),
                    onChanged: (value) {
                      controller.calculateChargeAmount();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the charge percentage';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: controller.chargeAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      controller.calculateChargeInPercent();
                    },
                    decoration: InputDecoration(labelText: 'Charge Amount'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the charge amount';
                      }
                      return null;
                    },
                  ),
                ),
              ]),
              SizedBox(height: 16),
              Row(children: [
                Expanded(child: Text('Total: ${controller.calculateTotal()}')),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    controller.processPayment(context);
                  },
                  style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all<Size>(
                          Size(size.width / 3, 38)),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Styles.primaryColor),
                      // controller.totalPayment() >=
                      //         captainOrderTransactionController
                      //             .totalTransactionPrice.value
                      //     ? Styles.primaryColor
                      //     : Styles.disabledColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Styles.defaultRadius),
                      ))),
                  child: const Text("Process Payment"),
                )
                    // ElevatedButton(
                    //   onPressed: () {
                    //     if (validateForm()) {
                    //       processPayment();
                    //     }
                    //   },
                    //   child: Text('Pay Now'),
                    // ),
                    ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpiryYearFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = _formatExpirationYear(newValue.text);
    return newValue.copyWith(
        text: text, selection: updateCursorPosition(text, newValue.selection));
  }

  String _formatExpirationYear(String input) {
    String cleanInput = input.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanInput.length > 2) {
      cleanInput = cleanInput.substring(0, 2);
    }
    return cleanInput;
  }

  TextSelection updateCursorPosition(
      String text, TextSelection currentSelection) {
    int selectionStart = currentSelection.start;
    int selectionEnd = currentSelection.end;

    final buffer = StringBuffer();
    int count = 0;
    for (int i = 0; i < text.length; i++) {
      if (count == selectionStart) {
        selectionStart = buffer.length;
      }
      if (count == selectionEnd) {
        selectionEnd = buffer.length;
      }
      final char = text[i];
      buffer.write(char);
      if (char != '/') {
        count++;
      }
    }
    if (count == selectionStart) {
      selectionStart = buffer.length;
    }
    if (count == selectionEnd) {
      selectionEnd = buffer.length;
    }

    return TextSelection(
        baseOffset: selectionStart,
        extentOffset: selectionEnd,
        affinity: currentSelection.affinity,
        isDirectional: currentSelection.isDirectional);
  }
}

class ExpiryMonthFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = _formatExpirationMonth(newValue.text);
    return newValue.copyWith(
        text: text, selection: updateCursorPosition(text, newValue.selection));
  }

  String _formatExpirationMonth(String input) {
    String cleanInput = input.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanInput.length > 2) {
      cleanInput = cleanInput.substring(0, 2);
    }
    return cleanInput;
  }

  TextSelection updateCursorPosition(
      String text, TextSelection currentSelection) {
    int selectionStart = currentSelection.start;
    int selectionEnd = currentSelection.end;

    final buffer = StringBuffer();
    int count = 0;
    for (int i = 0; i < text.length; i++) {
      if (count == selectionStart) {
        selectionStart = buffer.length;
      }
      if (count == selectionEnd) {
        selectionEnd = buffer.length;
      }
      final char = text[i];
      buffer.write(char);
      if (char != '/') {
        count++;
      }
    }
    if (count == selectionStart) {
      selectionStart = buffer.length;
    }
    if (count == selectionEnd) {
      selectionEnd = buffer.length;
    }

    return TextSelection(
        baseOffset: selectionStart,
        extentOffset: selectionEnd,
        affinity: currentSelection.affinity,
        isDirectional: currentSelection.isDirectional);
  }
}
