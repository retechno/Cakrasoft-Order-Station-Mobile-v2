import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:point_of_sales/models/report/captain_order.dart';
import 'package:point_of_sales/models/report/check.dart';
import 'package:point_of_sales/screens/pages/home/home_controller.dart';
import 'package:point_of_sales/utils/app_utils.dart';

class Printer {
  /// Audit date dari server; kosong/tidak valid dicetak "-" (bukan tanggal palsu).
  static String _cashierName() {
    try {
      return Get.find<HomeController>().user.value;
    } catch (_) {
      return "";
    }
  }

  static String _formatAuditDate(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed == null ? "-" : Formats.formatDate(parsed);
  }

  static Future<void> printReceipt(
      NetworkPrinter printer,
      CaptainOrder captainOrder,
      Company company,
      List<Transaction> transaction) async {
    // Print image
    if (company.foto != "") {
      final Uint8List bytes = base64Decode(company.foto);
      final Image? image = decodeImage(bytes);

      if (image != null) printer.image(image);
    }
    printer.text(company.name,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    printer.text("${company.street}, ${company.city}",
        styles: const PosStyles(align: PosAlign.center));
    printer.text("${company.state} ${company.country}",
        styles: const PosStyles(align: PosAlign.center));
    printer.text("Phone: ${company.phone1}, Website: ${company.website}",
        styles: const PosStyles(align: PosAlign.center));

    printer.hr();
    printer.row([
      PosColumn(text: 'CO#', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${captainOrder.idLog}',
          width: 6,
          styles: const PosStyles(bold: true)),
      PosColumn(text: 'T#', width: 1, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${captainOrder.tableNumber}',
          width: 3,
          styles: const PosStyles(bold: true)),
    ]);
    printer.row([
      PosColumn(text: 'Outlet', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${captainOrder.outlet}',
          width: 6,
          styles: const PosStyles(bold: true)),
      PosColumn(text: 'W', width: 1, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${captainOrder.waitress}',
          width: 3,
          styles: const PosStyles(bold: true)),
    ]);
    printer.row([
      PosColumn(text: 'Guest', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${captainOrder.fullName}',
          width: 6,
          styles: const PosStyles(bold: true)),
      PosColumn(text: '#A/#C', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${captainOrder.adult}/ ${captainOrder.child}',
          width: 2,
          styles: const PosStyles(bold: true)),
    ]);
    printer.hr();
    printer.row([
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Item', width: 4, styles: const PosStyles(bold: true)),
      PosColumn(
          text: 'Price',
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          text: 'Total',
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    for (var element in transaction) {
      printer.row([
        PosColumn(
            text: Formats.formatNumber(element.quantity.toString()), width: 2),
        PosColumn(text: element.description, width: 4),
        PosColumn(
            text: Formats.formatNumber(element.priceOriginal.toString()),
            width: 3,
            styles: const PosStyles(align: PosAlign.right)),
        PosColumn(
            text: Formats.formatNumber((element.totalPrice.toString())),
            width: 3,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      if (element.discount > 0) {
        // printer.text("Disc. ${element.discount}",
        //     styles: const PosStyles(align: PosAlign.left));
        printer.row([
          PosColumn(
              text: "  - Disc. ${Formats.formatNumber(element.discount)}",
              width: 12,
              styles: const PosStyles()),
        ]);
      }
    }
    printer.hr();
// TOTAL ================================

    printer.row([
      PosColumn(text: 'Sub Total', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(captainOrder.subTotal),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    printer.row([
      PosColumn(text: 'Discount', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(captainOrder.totalDiscount),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    printer.hr();
    printer.row([
      PosColumn(text: 'Price Sale', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(captainOrder.nettTotal),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    printer.row([
      PosColumn(text: 'Tax', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(captainOrder.totalTax),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    printer.row([
      PosColumn(text: 'Service', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(captainOrder.totalService),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    printer.hr(ch: '=');
    printer.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(captainOrder.grandTotal),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    printer.hr(ch: '=', linesAfter: 1);

    printer.row([
      PosColumn(
          text: 'Payment',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: Formats.formatNumber(captainOrder.totalPayment),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    printer.row([
      PosColumn(
          text: 'Change',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: Formats.formatNumber(
              (captainOrder.totalPayment - captainOrder.grandTotal) > 0
                  ? captainOrder.totalPayment - captainOrder.grandTotal
                  : 0),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    printer.feed(2);
    //Signature
    printer.row([
      PosColumn(
          text: '(_________________)',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '(_________________)',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.center,
          )),
    ]);
    printer.row([
      PosColumn(
          text: '  Cashier: ${_cashierName()}',
          width: 7,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '  Guest',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
    ]);

    // printer.text('(____________________)',
    //     styles: const PosStyles(align: PosAlign.center));
    // printer.text('Guest', styles: const PosStyles(align: PosAlign.center));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String auditDate =
        _formatAuditDate(captainOrder.auditDate);
    final String timestamp = formatter.format(now);

    printer.feed(2);
    printer.text('Printed: ${timestamp}',
        styles: const PosStyles(align: PosAlign.left));
    printer.text('Audit Date: ${auditDate}',
        styles: const PosStyles(align: PosAlign.left));

    printer.cut();
    printer.disconnect();
    print('Print result: ');
  }

  static Future<void> printReceiptBluetooth(
      BluetoothPrint printer,
      CaptainOrder captainOrder,
      Company company,
      List<Transaction> transaction,
      List<PaymentCaptainOrder> payment) async {
    int totalWidth = 32;
    String lineTotal = '-' * 17;
    String lineBreak = '*' * totalWidth;
    Map<String, dynamic> config = {};
    List<LineText> list = [];
    // Print image
    if (company.foto != "") {
      // list.add(LineText(
      //     type: LineText.TYPE_IMAGE,
      //     content: company.foto,
      //     align: LineText.ALIGN_CENTER,
      //     linefeed: 1));
    }

    // Centered header
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: company.name,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        weight: 2,
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "${company.street}",
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "${company.city} - ${company.state}",
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: company.country,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "Phone: ${company.phone1}",
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineBreak,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    // Receipt information
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "CO    :${captainOrder.idLog}",
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Wt    :${captainOrder.waitress}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '#A/#C : ${captainOrder.adult}/${captainOrder.child}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Doc#  : ${captainOrder.documentNumber}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Table#: ${captainOrder.tableNumber}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Comp  : ${captainOrder.complimentType}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Guest : ${captainOrder.fullName}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineBreak,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    String leftText = '';
    String rightText = '';
    int spacesCount = 0;
    String combinedText = '';
    //Product
    for (var element in transaction) {
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: element.description,
          align: LineText.ALIGN_LEFT,
          fontZoom: 1, // Smaller font size
          linefeed: 1));

      String leftText = Formats.formatNumber(element.quantity.toString());
      String rightText = Formats.formatNumber(element.totalPrice.toString());
      int spacesCount = totalWidth - (leftText.length + rightText.length);
      String combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: combinedText,
          align: LineText.ALIGN_LEFT,
          fontZoom: 1, // Smaller font size
          linefeed: 1));

      if (element.discount > 0) {
        // printer.text("Disc. ${element.discount}",
        //     styles: const PosStyles(align: PosAlign.left));

        leftText = '- Discount';
        rightText = '-${Formats.formatNumber(element.discount)}';
        spacesCount = totalWidth - (leftText.length + rightText.length);
        combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: combinedText,
            align: LineText.ALIGN_RIGHT,
            fontZoom: 1, // Smaller font size
            linefeed: 1));
      }
    }
//line
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineBreak,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Sub Total
    leftText =
        'Qty: ${Formats.formatNumber(captainOrder.totalQuantity)}, SubTotal:';
    rightText = Formats.formatNumber(captainOrder.subTotal);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Discount
    leftText = 'Discount';
    rightText = Formats.formatNumber(captainOrder.totalDiscount);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//line
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineTotal,
        align: LineText.ALIGN_RIGHT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Price Sale
    leftText = 'Price Sale';
    rightText = Formats.formatNumber(captainOrder.nettTotal);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
// Service
    leftText = 'Service:';
    rightText = Formats.formatNumber(captainOrder.totalService);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Tax
    leftText = 'Tax:';
    rightText = Formats.formatNumber(captainOrder.totalTax);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//  line
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineTotal,
        align: LineText.ALIGN_RIGHT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Grand Total
    leftText = 'Grand Total:';
    rightText = Formats.formatNumber(captainOrder.grandTotal);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        weight: 2,
        linefeed: 1));
// Payment
    leftText = 'Payment:';
    rightText = Formats.formatNumber(captainOrder.totalPayment);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        weight: 2,
        linefeed: 1));

    String paymentType = '';
    for (var element in payment) {
      if (paymentType != '') {
        paymentType += ', ';
      }
      paymentType += element.description;
    }
    if (paymentType != "") {
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '($paymentType)',
          align: LineText.ALIGN_LEFT,
          fontZoom: 1, // Smaller font size
          weight: 2,
          linefeed: 1));
    }
//line
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineTotal,
        align: LineText.ALIGN_RIGHT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//refund
    leftText = 'Refund:';
    rightText = Formats.formatNumber(
        (captainOrder.totalPayment - captainOrder.grandTotal) > 0
            ? captainOrder.totalPayment - captainOrder.grandTotal
            : 0);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    //Sign
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: ' ',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: ' ',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: ' ',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    leftText = '(________)';
    rightText = '(________)';
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    leftText = ' Cashier';
    rightText = 'Guest  ';
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '*' * totalWidth,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Cashier: ${_cashierName()}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String auditDate =
        _formatAuditDate(captainOrder.auditDate);
    final String timestamp = formatter.format(now);
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Printed: ${timestamp}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Audit Date: ${auditDate}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineBreak,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    await printer.printReceipt(config, list);
  }

  static Future<void> printCheckBluetooth(
      BluetoothPrint printer,
      Check check,
      Company company,
      List<CheckTransaction> transaction,
      List<Payment> payment) async {
    int totalWidth = 32;
    String lineTotal = '-' * 17;
    String lineBreak = '*' * totalWidth;
    Map<String, dynamic> config = {};
    List<LineText> list = [];
    // Print image
    if (company.foto != "") {
      // list.add(LineText(
      //     type: LineText.TYPE_IMAGE,
      //     content: company.foto,
      //     align: LineText.ALIGN_CENTER,
      //     linefeed: 1));
    }

    // Centered header
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: company.name,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        weight: 2,
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: company.street,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "${company.city} - ${company.state}",
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: company.country,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "Phone: ${company.phone1}",
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineBreak,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    // Receipt information
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "Check :${check.number}",
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Wt    :${check.waitress}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '#A/#C : ${check.adult}/${check.child}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Doc#  : ${check.documentNumber}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Table#: ${check.tableNumber}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Comp  : ${check.complimentType}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Guest : ${check.fullName}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineBreak,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    String leftText = '';
    String rightText = '';
    int spacesCount = 0;
    String combinedText = '';
    //Product
    for (var element in transaction) {
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: element.descriptionFree,
          align: LineText.ALIGN_LEFT,
          fontZoom: 1, // Smaller font size
          linefeed: 1));

      String leftText = Formats.formatNumber(element.quantity.toString());
      String rightText = Formats.formatNumber(element.totalPrice.toString());
      int spacesCount = totalWidth - (leftText.length + rightText.length);
      String combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: combinedText,
          align: LineText.ALIGN_LEFT,
          fontZoom: 1, // Smaller font size
          linefeed: 1));

      if (element.discount > 0) {
        // printer.text("Disc. ${element.discount}",
        //     styles: const PosStyles(align: PosAlign.left));

        leftText = '- Discount';
        rightText = '-${Formats.formatNumber(element.discount)}';
        spacesCount = totalWidth - (leftText.length + rightText.length);
        combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: combinedText,
            align: LineText.ALIGN_RIGHT,
            fontZoom: 1, // Smaller font size
            linefeed: 1));
      }
    }
//line
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineBreak,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Sub Total
    leftText = 'Qty: ${Formats.formatNumber(check.totalQuantity)}, SubTotal:';
    rightText = Formats.formatNumber(check.subTotal);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Discount
    leftText = 'Discount';
    rightText = Formats.formatNumber(check.totalDiscount);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//line
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineTotal,
        align: LineText.ALIGN_RIGHT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Price Sale
    leftText = 'Price Sale';
    rightText = Formats.formatNumber(check.nettTotal);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
// Service
    leftText = 'Service:';
    rightText = Formats.formatNumber(check.totalService);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Tax
    leftText = 'Tax:';
    rightText = Formats.formatNumber(check.totalTax);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//  line
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineTotal,
        align: LineText.ALIGN_RIGHT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//Grand Total
    leftText = 'Grand Total:';
    rightText = Formats.formatNumber(check.grandTotal);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        weight: 2,
        linefeed: 1));
// Payment
    leftText = 'Payment:';
    rightText = Formats.formatNumber(check.totalPayment);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        weight: 2,
        linefeed: 1));

    String paymentType = '';
    for (var element in payment) {
      if (paymentType != '') {
        paymentType += ', ';
      }
      paymentType += element.accountName;
    }
    if (paymentType != "") {
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '($paymentType)',
          align: LineText.ALIGN_LEFT,
          fontZoom: 1, // Smaller font size
          weight: 2,
          linefeed: 1));
    }
//line
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineTotal,
        align: LineText.ALIGN_RIGHT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
//refund
    leftText = 'Refund:';
    rightText = Formats.formatNumber((check.totalPayment - check.grandTotal) > 0
        ? check.totalPayment - check.grandTotal
        : 0);
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    //Sign
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: ' ',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: ' ',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: ' ',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    leftText = '(________)';
    rightText = '(________)';
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    leftText = ' Cashier';
    rightText = 'Guest  ';
    spacesCount = totalWidth - (leftText.length + rightText.length);
    combinedText = leftText + ' ' * (spacesCount < 1 ? 1 : spacesCount) + rightText;
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: combinedText,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '*' * totalWidth,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Cashier: ${_cashierName()}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String auditDate =
        _formatAuditDate(check.auditDate);
    final String timestamp = formatter.format(now);
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Printed: ${timestamp}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Audit Date: ${auditDate}',
        align: LineText.ALIGN_LEFT,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: lineBreak,
        align: LineText.ALIGN_CENTER,
        fontZoom: 1, // Smaller font size
        linefeed: 1));

    await printer.printReceipt(config, list);
  }

// Print Check
  static Future<void> printCheck(NetworkPrinter printer, Check check,
      Company company, List<CheckTransaction> transaction) async {
    // Print image
    if (company.foto != "") {
      final Uint8List bytes = base64Decode(company.foto);
      final Image? image = decodeImage(bytes);

      if (image != null) printer.image(image);
    }
    printer.text(company.name,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    printer.text("${company.street}, ${company.city}",
        styles: const PosStyles(align: PosAlign.center));
    printer.text("${company.state} ${company.country}",
        styles: const PosStyles(align: PosAlign.center));
    printer.text("Phone: ${company.phone1}, Website: ${company.website}",
        styles: const PosStyles(align: PosAlign.center));

    printer.hr();
    printer.row([
      PosColumn(text: 'Check#', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${check.number}',
          width: 6,
          styles: const PosStyles(bold: true)),
      PosColumn(text: 'T#', width: 1, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${check.tableNumber}',
          width: 3,
          styles: const PosStyles(bold: true)),
    ]);
    printer.row([
      PosColumn(text: 'Outlet', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${check.outlet}',
          width: 6,
          styles: const PosStyles(bold: true)),
      PosColumn(text: 'W', width: 1, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${check.waitress}',
          width: 3,
          styles: const PosStyles(bold: true)),
    ]);
    printer.row([
      PosColumn(text: 'Guest', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${check.fullName}',
          width: 6,
          styles: const PosStyles(bold: true)),
      PosColumn(text: '#A/#C', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(
          text: ': ${check.adult}/ ${check.child}',
          width: 2,
          styles: const PosStyles(bold: true)),
    ]);
    printer.hr();
    printer.row([
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Item', width: 4, styles: const PosStyles(bold: true)),
      PosColumn(
          text: 'Price',
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          text: 'Total',
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    for (var element in transaction) {
      printer.row([
        PosColumn(
            text: Formats.formatNumber(element.quantity.toString()), width: 2),
        PosColumn(text: element.descriptionFree, width: 4),
        PosColumn(
            text: Formats.formatNumber(element.priceOriginal.toString()),
            width: 3,
            styles: const PosStyles(align: PosAlign.right)),
        PosColumn(
            text: Formats.formatNumber((element.totalPrice.toString())),
            width: 3,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      if (element.discount > 0) {
        // printer.text("Disc. ${element.discount}",
        //     styles: const PosStyles(align: PosAlign.left));
        printer.row([
          PosColumn(
              text: "  - Disc. ${Formats.formatNumber(element.discount)}",
              width: 12,
              styles: const PosStyles()),
        ]);
      }
    }
    printer.hr();
    // TOTAL ================================

    printer.row([
      PosColumn(text: 'Sub Total', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(check.subTotal.toString()),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    printer.row([
      PosColumn(text: 'Discount', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(check.totalDiscount.toString()),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    printer.hr();
    printer.row([
      PosColumn(text: 'Price Sale', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(check.nettTotal.toString()),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    printer.row([
      PosColumn(text: 'Tax', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(check.totalTax.toString()),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    printer.row([
      PosColumn(text: 'Service', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(check.totalService.toString()),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    printer.hr(ch: '=');
    printer.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles()),
      PosColumn(
          text: Formats.formatNumber(check.grandTotal.toString()),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    printer.hr(ch: '=', linesAfter: 1);

    printer.row([
      PosColumn(
          text: 'Payment',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: Formats.formatNumber(check.totalPayment),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    printer.row([
      PosColumn(
          text: 'Change',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: Formats.formatNumber((check.totalPayment - check.grandTotal) > 0
              ? check.totalPayment - check.grandTotal
              : 0),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    printer.feed(2);
    //Signature

    printer.row([
      PosColumn(
          text: '(_________________)',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '(_________________)',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.center,
          )),
    ]);
    printer.row([
      PosColumn(
          text: '  Cashier: ${_cashierName()}',
          width: 7,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '  Guest',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
    ]);

    // printer.text('(____________________)',
    //     styles: const PosStyles(align: PosAlign.center));
    // printer.text('Guest', styles: const PosStyles(align: PosAlign.center));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String auditDate =
        _formatAuditDate(check.auditDate);
    final String timestamp = formatter.format(now);

    printer.feed(2);
    printer.text('Printed: ${timestamp}',
        styles: const PosStyles(align: PosAlign.left));
    printer.text('Audit Date: ${auditDate}',
        styles: const PosStyles(align: PosAlign.left));

    printer.cut();
    printer.disconnect();
    print('Print result: ');
  }
}
