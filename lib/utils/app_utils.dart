import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:point_of_sales/widget/alert_widget.dart';

// Color primary = Color.fromARGB(255, 0, 144, 29);
Color primary = const Color.fromARGB(255, 2, 120, 1);

class Styles {
  static double defaultHeightCard = 58;
  static double defaultHeightButton = 38;
  static double defaultHeightInputField = 38;
  static double defaultPadding = 7.0;
  static double defaultRadius = 10.0;
  static double changeQuantityButtonSize = 25;
  static double changeQuantityButtonWidth = 50;
  static String fontFamily = "Inter";
  static Color primaryColor = primary;
  static Color dangerColor = const Color.fromARGB(255, 204, 48, 59);
  static Color textColor = const Color(0xFF3b3b3b);
  static Color disabledColor = const Color.fromARGB(255, 124, 124, 124);
  static Color textInactive = disabledColor;
  static Color textColorButton = const Color.fromARGB(255, 255, 255, 255);
  static Color textDetailColor = const Color.fromARGB(255, 111, 111, 111);
  static Color bgColor = const Color(0xFFeeedf2);
  static EdgeInsets paddingBody = const EdgeInsets.all(10);
  static EdgeInsets paddingDialog = const EdgeInsets.all(20);
  static TextStyle textStyle = TextStyle(
      fontSize: 13,
      color: textColor,
      fontWeight: FontWeight.w500,
      fontFamily: fontFamily);
  static TextStyle textStyle2 = TextStyle(
      fontSize: 11,
      color: textColor,
      fontWeight: FontWeight.w500,
      fontFamily: fontFamily);
  static TextStyle textDetailStyle = TextStyle(
      fontSize: 10,
      color: textDetailColor,
      fontWeight: FontWeight.w500,
      fontFamily: fontFamily);
  static TextStyle textDetailStyle2 = TextStyle(
      fontSize: 12,
      color: textDetailColor,
      fontWeight: FontWeight.w500,
      fontFamily: fontFamily);
  static TextStyle headLineStyle = TextStyle(
      fontSize: 24,
      color: textColor,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily);
  static TextStyle headLineStyle1 = TextStyle(
      fontSize: 20,
      color: textColor,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily);
  static TextStyle headLineStyle2 = TextStyle(
      fontSize: 18,
      color: textColor,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily);
  static TextStyle headLineStyle3 = TextStyle(
      fontSize: 16,
      color: textColor,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily);
  static TextStyle headLineStyle4 = TextStyle(
      fontSize: 14,
      color: textColor,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily);
  static TextStyle textButton = TextStyle(
      fontSize: 18,
      color: textColorButton,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily);
  static TextStyle textButton2 = TextStyle(
      fontSize: 14,
      color: textColorButton,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily);
}

class Formats {
  static formatNumber(value) {
    value = num.parse(value.toString().replaceAll(',', ''));
    if (value == 0) return "0.00";
    var formatter = NumberFormat.currency(
        locale: "id_ID", symbol: "", name: "", decimalDigits: 2);

    return formatter.format(value);
  }

  static formatCurrency(String value) {
    if (value.isEmpty) return "0";
    var valueX = value.replaceAll(',00', '');
    valueX = valueX.replaceAll('.', '');
    double valueD = double.parse(valueX);
    var formatter = NumberFormat.currency(
        locale: "id_ID", symbol: "", name: "", decimalDigits: 0);

    return formatter.format(valueD);
  }

  static currencyToNumber(String value) {
    String valueX = value.replaceAll('.', '');
    return valueX;
  }

  static formatUppercase(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }

  static formatDateMonth(String? date) {
    if (date == null || date == "") return "";
    var splitted = date.split('T');
    var res = splitted[0].substring(5);
    res = res.replaceAll('-', '/');
    return res;
  }

  static formatDate(DateTime date) {
    final format = DateFormat('dd/MM/yyyy');
    return format.format(date);
  }

  static formatTime(DateTime date) {
    final format = DateFormat('HH:mm:ss');
    return format.format(date);
  }

  static double parseDoubleWithLocale(String value) {
    final format = NumberFormat.decimalPattern();
    final number = format.parse(value);
    return number.toDouble();
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID');

    String newText = formatter.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}

void showAlert(BuildContext context, String text) {
  // konteks bisa sudah tidak ada (layar ditutup saat menunggu server)
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertWidget(
        title: "Information",
        content: text,
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
