
import 'package:point_of_sales/utils/app_utils.dart';

class Check {
  String address;
  String complimentType;
  double nettTotal;
  String outlet;
  double service;
  String subDepartment;
  num subTotal;
  num tax;
  num totalCardCharge;
  num totalDiscount;
  num totalPayment;
  num totalQuantity;
  num totalService;
  num totalTax;
  num grandTotal;
  String type;
  String waitress;
  int adult;
  String auditDate;
  int captainOrderId;
  int child;
  String complimentTypeCode;
  String documentNumber;
  int folioNumber;
  String fullName;
  int idLog;
  String number;
  String remark;
  String tableNumber;
  String titleCode;
  String userId;

  Check({
    this.address = "",
    this.complimentType = "",
    this.nettTotal = 0,
    this.outlet = "",
    this.service = 0,
    this.subDepartment = "",
    this.subTotal = 0,
    this.tax = 0,
    this.totalCardCharge = 0,
    this.totalDiscount = 0,
    this.totalPayment = 0,
    this.totalQuantity = 0,
    this.totalService = 0,
    this.totalTax = 0,
    this.grandTotal = 0,
    this.type = "",
    this.waitress = "",
    this.adult = 0,
    this.auditDate = "",
    this.captainOrderId = 0,
    this.child = 0,
    this.complimentTypeCode = "",
    this.documentNumber = "",
    this.folioNumber = 0,
    this.fullName = "",
    this.idLog = 0,
    this.number = "",
    this.remark = "",
    this.tableNumber = "",
    this.titleCode = "",
    this.userId = "",
  });
  factory Check.fromJson(Map<String, dynamic> json) {
    return Check(
      address: json['Address'] ?? "",
      complimentType: json['ComplimentType'] ?? "",
      nettTotal: double.tryParse(json['NettTotal'].toString()) ?? 0,
      outlet: json['Outlet'] ?? "",
      service: double.tryParse(json['Service'].toString()) ?? 0,
      subDepartment: json['SubDepartment'] ?? "",
      subTotal: num.tryParse(json['SubTotal'].toString()) ?? 0,
      tax: num.tryParse(json['Tax'].toString()) ?? 0,
      totalCardCharge: double.tryParse(json['TotalCardCharge'].toString()) ?? 0,
      totalDiscount: double.tryParse(json['TotalDiscount'].toString()) ?? 0,
      totalPayment: double.tryParse(json['TotalPayment'].toString()) ?? 0,
      totalQuantity: double.tryParse(json['TotalQuantity'].toString()) ?? 0,
      totalService: double.tryParse(json['TotalService'].toString()) ?? 0,
      totalTax: double.tryParse(json['TotalTax'].toString()) ?? 0,
      grandTotal: double.tryParse(json['GrandTotal'].toString()) ?? 0,
      type: json['Type'] ?? "",
      waitress: json['Waitress'] ?? "",
      adult: json['adult'] ?? 0,
      auditDate: json['audit_date'] ?? "",
      captainOrderId: json['captain_order_id'] ?? 0,
      child: json['child'] ?? 0,
      complimentTypeCode: json['compliment_type_code'] ?? "",
      documentNumber: json['document_number'] ?? "",
      folioNumber: json['folio_number'] ?? 0,
      fullName: json['full_name'] ?? "",
      idLog: json['id_log'] ?? 0,
      number: json['number'] ?? "",
      remark: json['remark'] ?? "",
      tableNumber: json['table_number'] ?? "",
      titleCode: json['title_code'] ?? "",
      userId: json['user_id'] ?? "",
    );
  }
}

class Payment {
  String accountName;
  int captainOrderTransactionId;
  String cardCharge;
  String checkNumber;
  String companyCode;
  String companyCode2;
  String discount;
  String estimationCost;
  int folioTransfer;
  int idLog;
  String inventoryCode;
  String isCompliment;
  String isFree;
  String price;
  String priceOriginal;
  String pricePurchase;
  String productCode;
  String quantity;
  int seatNumber;
  String service;
  int subFolioId;
  String tax;
  String tenanCode;
  String userId;

  Payment({
    this.accountName = "",
    this.captainOrderTransactionId = 0,
    this.cardCharge = "",
    this.checkNumber = "",
    this.companyCode = "",
    this.companyCode2 = "",
    this.discount = "",
    this.estimationCost = "",
    this.folioTransfer = 0,
    this.idLog = 0,
    this.inventoryCode = "",
    this.isCompliment = "",
    this.isFree = "",
    this.price = "",
    this.priceOriginal = "",
    this.pricePurchase = "",
    this.productCode = "",
    this.quantity = "",
    this.seatNumber = 0,
    this.service = "",
    this.subFolioId = 0,
    this.tax = "",
    this.tenanCode = "",
    this.userId = "",
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      accountName: json['AccountName'] ?? "",
      captainOrderTransactionId: json['captain_order_transaction_id'] ?? 0,
      cardCharge: json['card_charge'] ?? "",
      checkNumber: json['check_number'] ?? "",
      companyCode: json['company_code'] ?? "",
      companyCode2: json['company_code2'] ?? "",
      discount: json['discount'] ?? "",
      estimationCost: json['estimation_cost'] ?? "",
      folioTransfer: json['folio_transfer'] ?? 0,
      idLog: json['id_log'] ?? 0,
      inventoryCode: json['inventory_code'] ?? "",
      isCompliment: json['is_compliment'] ?? "",
      isFree: json['is_free'] ?? "",
      price: json['price'] ?? "",
      priceOriginal: json['price_original'] ?? "",
      pricePurchase: json['price_purchase'] ?? "",
      productCode: json['product_code'] ?? "",
      quantity: json['quantity'] ?? "",
      seatNumber: json['seat_number'] ?? 0,
      service: json['service'] ?? "",
      subFolioId: json['sub_folio_id'] ?? 0,
      tax: json['tax'] ?? "",
      tenanCode: json['tenan_code'] ?? "",
      userId: json['user_id'] ?? "",
    );
  }
}

class CheckTransaction {
  String descriptionFree;
  int captainOrderTransactionId;
  num cardCharge;
  String checkNumber;
  String companyCode;
  String companyCode2;
  num discount;
  num estimationCost;
  int folioTransfer;
  int idLog;
  num totalPrice;
  String inventoryCode;
  String isCompliment;
  String isFree;
  num price;
  num priceOriginal;
  num pricePurchase;
  String productCode;
  num quantity;
  int seatNumber;
  num service;
  int subFolioId;
  num tax;
  String tenanCode;
  String userId;

  CheckTransaction({
    this.descriptionFree = "",
    this.captainOrderTransactionId = 0,
    this.cardCharge = 0,
    this.checkNumber = "",
    this.companyCode = "",
    this.companyCode2 = "",
    this.discount = 0,
    this.estimationCost = 0,
    this.folioTransfer = 0,
    this.totalPrice = 0,
    this.idLog = 0,
    this.inventoryCode = "",
    this.isCompliment = "",
    this.isFree = "",
    this.price = 0,
    this.priceOriginal = 0,
    this.pricePurchase = 0,
    this.productCode = "",
    this.quantity = 0,
    this.seatNumber = 0,
    this.service = 0,
    this.subFolioId = 0,
    this.tax = 0,
    this.tenanCode = "",
    this.userId = "",
  });

  factory CheckTransaction.fromJson(Map<String, dynamic> json) {
    return CheckTransaction(
      descriptionFree: json['DescriptionFree'] ?? "",
      captainOrderTransactionId: json['captain_order_transaction_id'] ?? 0,
      cardCharge: Formats.parseDoubleWithLocale(json['card_charge'] ?? "0"),
      checkNumber: json['check_number'] ?? "",
      companyCode: json['company_code'] ?? "",
      companyCode2: json['company_code2'] ?? "",
      discount: Formats.parseDoubleWithLocale(json['discount'] ?? "0"),
      estimationCost:
          Formats.parseDoubleWithLocale(json['estimation_cost'] ?? "0"),
      folioTransfer: json['folio_transfer'] ?? 0,
      idLog: json['id_log'] ?? 0,
      totalPrice: Formats.parseDoubleWithLocale(json['total_price'] ?? "0"),
      inventoryCode: json['inventory_code'] ?? "",
      isCompliment: json['is_compliment'] ?? "",
      isFree: json['is_free'] ?? "",
      price: Formats.parseDoubleWithLocale(json['price'] ?? "0"),
      priceOriginal:
          Formats.parseDoubleWithLocale(json['price_original'] ?? "0"),
      pricePurchase:
          Formats.parseDoubleWithLocale(json['price_purchase'] ?? "0"),
      productCode: json['product_code'] ?? "",
      quantity: Formats.parseDoubleWithLocale(json['quantity'] ?? "0"),
      seatNumber: json['seat_number'] ?? 0,
      service: Formats.parseDoubleWithLocale(json['service'] ?? "0"),
      subFolioId: json['sub_folio_id'] ?? 0,
      tax: Formats.parseDoubleWithLocale(json['tax'] ?? "0"),
      tenanCode: json['tenan_code'] ?? "",
      userId: json['user_id'] ?? "",
    );
  }
}
