import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/code_name.dart';
import 'package:point_of_sales/models/payment_data.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/captain_order_transaction_controller.dart';
import 'package:point_of_sales/screens/pages/captain_order/transaction/payment/payment_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';
import 'package:point_of_sales/utils/request.dart';

class CityLedgerPaymentController extends GetxController {
  final CaptainOrderTransactionController captainOrderTransactionController =
      Get.find<CaptainOrderTransactionController>();
  final PaymentController paymentController = Get.find<PaymentController>();

  TextEditingController amountController = TextEditingController();

  // Company terpilih (kode) dari dropdown di layar.
  Rxn<String> company = Rxn<String>();
  // RxString selectedCompany = "A".obs;

  RxList<CodeName> companies = <CodeName>[].obs;

  FocusNode amountFocusNode = FocusNode();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getComboList();
  }

  bool validateForm() {
    return amountController.text.isNotEmpty && (company.value ?? "").isNotEmpty;
  }

  //API
  getComboList() {
    Request request = Request(url: 'GetARCompanies');
    request.get().then((value) {
      if (value.statusCode == 200) {
        try {
          Map result = jsonDecode(value.body);
          if (result["Result"] == null) return;
          List data = result["Result"];
          companies.clear();
          companies.value = data.map((e) => CodeName.fromJson(e)).toList();
          companies.refresh();
        } catch (e) {
          print(e);
        }
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    }).catchError((onError) {
      printError();
    });
  }

  processPayment(BuildContext context) {
    final companyCode = company.value ?? "";
    if (companyCode.isEmpty) {
      showAlert(context, "Please select a company first");
      return;
    }
    num amount =
        parseDoubleFromText(Formats.currencyToNumber(amountController.text));
    paymentController.confirmPayment(
      context,
      amount,
      PaymentData(
          captainOrderId: paymentController.captainOrderId.value,
          accountCode: paymentController.accountCode.value,
          accountName: paymentController.accountName.value,
          paymentAmount: amount,
          companyCode: companyCode),
    );
  }

  double parseDoubleFromText(String text) {
    final cleanedText = text.replaceAll(RegExp(r'[^0-9.]'), '');
    final numericValue = double.tryParse(cleanedText);
    return numericValue ?? 0.0; // Provide a default value if parsing fails
  }
}
