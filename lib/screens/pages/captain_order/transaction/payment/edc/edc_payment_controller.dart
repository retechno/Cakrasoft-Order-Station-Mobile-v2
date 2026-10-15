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

class EDCPaymentController extends GetxController {
  TextEditingController amountController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryMonthController = TextEditingController();
  TextEditingController expiryYearController = TextEditingController();
  TextEditingController chargeInPercentController = TextEditingController();
  TextEditingController chargeAmountController = TextEditingController();

  final CaptainOrderTransactionController captainOrderTransactionController =
      Get.find<CaptainOrderTransactionController>();
  final PaymentController paymentController = Get.find<PaymentController>();

  Rx<CodeName> selectedCardType = CodeName(code: "D", name: "Debit").obs;
  Rx<CodeName> selectedBankCard = CodeName(code: "BCA", name: "BCA").obs;

  RxList<CodeName> cardTypes = <CodeName>[].obs;
  RxList<CodeName> bankCards = <CodeName>[].obs;

  FocusNode amountFocusNode = FocusNode();

  // true setelah daftar bank/kartu berhasil dimuat dari server. Default
  // lokal (BCA/Debit) tidak boleh terkirim bila daftar belum termuat.
  bool comboLoaded = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    cardTypes.add(CodeName(code: "D", name: "Debit"));
    bankCards.add(CodeName(code: "BCA", name: "BCA"));
    await getComboList();
    amountFocusNode.requestFocus();
  }

  // Amount memakai format currency id_ID ("1.000"), jadi tidak boleh di-parse
  // langsung dengan double.tryParse. Charge diketik user: koma/titik diterima.
  double _amountValue() =>
      parseDoubleFromText(Formats.currencyToNumber(amountController.text));

  double _decimalValue(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.')) ?? 0;

  void calculateChargeInPercent() {
    double amount = _amountValue();
    double chargeAmount = _decimalValue(chargeAmountController.text);

    if (amount <= 0) {
      chargeInPercentController.text = "0.00";
      return;
    }
    double chargeInPercent = (chargeAmount / amount) * 100;
    if (chargeInPercent.isNaN || chargeInPercent.isInfinite) {
      chargeInPercent = 0;
    }

    chargeInPercentController.text = chargeInPercent.toStringAsFixed(2);
  }

  void calculateChargeAmount() {
    double amount = _amountValue();
    double chargeInPercent = _decimalValue(chargeInPercentController.text);

    double chargeAmount = (amount * chargeInPercent) / 100;

    chargeAmountController.text = chargeAmount.toStringAsFixed(2);
  }

  double calculateTotal() {
    return _amountValue() + _decimalValue(chargeAmountController.text);
  }

  bool validateForm() {
    final month = int.tryParse(expiryMonthController.text) ?? 0;
    return amountController.text.isNotEmpty &&
        cardNumberController.text.trim().isNotEmpty &&
        month >= 1 &&
        month <= 12 &&
        expiryYearController.text.length == 2;
  }

  //API
  Future<void> getComboList() {
    Request request = Request(url: 'GetPaymentEDCComboList');
    return request.get().then((value) {
      if (value.statusCode == 200) {
        Map result = jsonDecode(value.body);
        if (result["Result"] == null) return;
        Map data = result["Result"];
        List card = data["card_type"];
        List bank = data["bank_type"];
        cardTypes.clear();
        bankCards.clear();
        cardTypes.value = card.map((e) => CodeName.fromJson(e)).toList();
        bankCards.value = bank.map((e) => CodeName.fromJson(e)).toList();
        if (bankCards.isNotEmpty &&
            !bankCards.contains(selectedBankCard.value)) {
          selectedBankCard.value = bankCards.first;
        }
        if (cardTypes.isNotEmpty &&
            !cardTypes.contains(selectedCardType.value)) {
          selectedCardType.value = cardTypes.first;
        }
        comboLoaded = bankCards.isNotEmpty && cardTypes.isNotEmpty;
      } else {
        if (kDebugMode) {
          print('Backend error');
        }
      }
    }).catchError((onError) {
      printError();
    });
  }

  processPayment(BuildContext context) async {
    if (!comboLoaded) {
      // coba muat ulang sekali sebelum menolak
      await getComboList();
      if (!context.mounted) return;
      if (!comboLoaded) {
        showAlert(context,
            "Daftar bank/jenis kartu belum termuat dari server. Coba lagi.");
        return;
      }
    }
    if (!validateForm()) {
      showAlert(context,
          "Please fill amount, card number and a valid expiry date (MM/YY)");
      return;
    }
    num amount =
        parseDoubleFromText(Formats.currencyToNumber(amountController.text));
    double charge = _decimalValue(chargeAmountController.text);
    if (charge.isNaN || charge.isInfinite || charge < 0) charge = 0.0;
    paymentController.confirmPayment(
      context,
      amount,
      PaymentData(
        captainOrderId: paymentController.captainOrderId.value,
        accountCode: paymentController.accountCode.value,
        accountName: paymentController.accountName.value,
        paymentAmount: amount,
        cardBankCode: selectedBankCard.value.code,
        cardTypeCode: selectedCardType.value.code,
        cardCharge: charge,
        cardNumber: cardNumberController.text.trim(),
        validMonth: expiryMonthController.text.trim(),
        validYear: expiryYearController.text.trim(),
      ),
    );
  }

  double parseDoubleFromText(String text) {
    final cleanedText = text.replaceAll(RegExp(r'[^0-9.]'), '');
    final numericValue = double.tryParse(cleanedText);
    return numericValue ?? 0.0; // Provide a default value if parsing fails
  }
}
