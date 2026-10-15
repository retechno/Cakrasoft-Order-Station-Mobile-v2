import 'package:point_of_sales/utils/app_utils.dart';

class PrintCaptainOrderData {
  Company? company;
  Data? data;
  String? template;

  PrintCaptainOrderData({
    this.company,
    this.data,
    this.template,
  });

  factory PrintCaptainOrderData.fromJson(Map<String, dynamic> json) {
    return PrintCaptainOrderData(
      company: Company.fromJson(json['company']),
      data: Data.fromJson(json['data']),
      template: json['template'] ?? '',
    );
  }
}

class Company {
  String country;
  String state;
  String city;
  String code;
  String countryCode;
  String email;
  String fax;
  String foto;
  String name;
  String phone1;
  String phone2;
  String postalCode;
  String stateCode;
  String street;
  String website;

  Company({
    this.country = "",
    this.state = "",
    this.city = "",
    required this.code,
    this.countryCode = "",
    this.email = "",
    this.fax = "",
    this.foto = "",
    this.name = "",
    this.phone1 = " =" "",
    this.phone2 = "",
    this.postalCode = "",
    this.stateCode = "",
    this.street = "",
    this.website = "",
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      country: json['Country'] ?? '',
      state: json['State'] ?? '',
      city: json['City'] ?? '',
      code: json['Code'] ?? '',
      countryCode: json['CountryCode'] ?? '',
      email: json['Email'] ?? '',
      fax: json['Fax'] ?? '',
      foto: json['Foto'] ?? '',
      name: json['Name'] ?? '',
      phone1: json['Phone1'] ?? '',
      phone2: json['Phone2'] ?? '',
      postalCode: json['PostalCode'] ?? '',
      stateCode: json['StateCode'] ?? '',
      street: json['Street'] ?? '',
      website: json['Website'] ?? '',
    );
  }
}

class Data {
  CaptainOrder captainOrder;
  List<Transaction> transactions;

  Data({
    required this.captainOrder,
    required this.transactions,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      captainOrder: CaptainOrder.fromJson(json['captain_order']),
      transactions: List<Transaction>.from(
        json['transactions']?.map((x) => Transaction.fromJson(x)) ?? [],
      ),
    );
  }
}

class CaptainOrder {
  String? complimentType;
  double nettTotal;
  String? outlet;
  double? service;
  String? subDepartment;
  double? subTotal;
  double? tax;
  double? totalCardCharge;
  double? totalDiscount;
  double totalPayment;
  double? totalQuantity;
  double? totalService;
  double? totalTax;
  double grandTotal;
  String? type;
  String? waitress;
  int? adult;
  String auditDate;
  String? cancelBy;
  String? cancelDate;
  String? cancelReason;
  int? child;
  String? complimentTypeCode;
  String? documentNumber;
  String? fullName;
  int? idLog;
  String? isCancel;
  String? remark;
  String? tableNumber;
  String? titleCode;

  CaptainOrder({
    this.complimentType,
    this.nettTotal = 0,
    this.outlet,
    this.service,
    this.subDepartment,
    this.subTotal,
    this.tax,
    this.totalCardCharge,
    this.totalDiscount,
    this.totalPayment = 0,
    this.totalQuantity,
    this.totalService,
    this.totalTax,
    this.grandTotal = 0,
    this.type,
    this.waitress,
    this.adult,
    this.auditDate = '',
    this.cancelBy,
    this.cancelDate,
    this.cancelReason,
    this.child,
    this.complimentTypeCode,
    this.documentNumber,
    this.fullName,
    this.idLog,
    this.isCancel,
    this.remark,
    this.tableNumber,
    this.titleCode,
  });

  factory CaptainOrder.fromJson(Map<String, dynamic> json) {
    return CaptainOrder(
      complimentType: json['ComplimentType'] ?? '',
      nettTotal: double.parse(json['NettTotal'] ?? '0'),
      outlet: json['Outlet'] ?? '',
      service: double.parse(json['Service'] ?? ''),
      subDepartment: json['SubDepartment'] ?? '',
      subTotal: double.parse(json['SubTotal'] ?? ''),
      tax: double.parse(json['Tax'] ?? ''),
      totalCardCharge: double.parse(json['TotalCardCharge'] ?? ''),
      totalDiscount: double.parse(json['TotalDiscount'] ?? ''),
      totalPayment: double.parse(json['TotalPayment'] ?? ''),
      totalQuantity: double.parse(json['TotalQuantity'] ?? ''),
      totalService: double.parse(json['TotalService'] ?? ''),
      totalTax: double.parse(json['TotalTax'] ?? ''),
      grandTotal: double.parse(json['GrandTotal'] ?? ''),
      type: json['Type'] ?? '',
      waitress: json['Waitress'] ?? '',
      adult: json['adult'] ?? 0,
      auditDate: json['audit_date'] ?? '',
      cancelBy: json['cancel_by'] ?? '',
      cancelDate: json['cancel_date'] ?? '',
      cancelReason: json['cancel_reason'] ?? '',
      child: json['child'] ?? 0,
      complimentTypeCode: json['compliment_type_code'] ?? '',
      documentNumber: json['document_number'] ?? '',
      fullName: json['full_name'] ?? '',
      idLog: json['id_log'] ?? 0,
      isCancel: json['is_cancel'] ?? '',
      remark: json['remark'] ?? '',
      tableNumber: json['table_number'] ?? '',
      titleCode: json['title_code'] ?? '',
    );
  }
}

class Transaction {
  String descriptionFree;
  String accountCode;
  String auditDate;
  int captainOrderId;
  String cardBankCode;
  double cardCharge;
  String cardHolder;
  String cardNumber;
  String cardTypeCode;
  String companyCode;
  String companyCode2;
  String currencyCode;
  String defaultCurrencyCode;
  String description;
  double discount;
  double discountTemp;
  double exchangeRate;
  int folioTransfer;
  int idLog;
  String inventoryCode;
  String isCompliment;
  String isFree;
  String isRemove;
  int logShiftId;
  String postingDate;
  double price;
  double priceOriginal;
  double pricePurchase;
  String productCode;
  double quantity;
  double quantityPrinted;
  double quantityPrintedCheck;
  double totalPrice;
  String remark;
  String removeBy;
  String removeDate;
  int seatNumber;
  double service;
  String shift;
  String spaEndDate;
  String spaRoomNumber;
  String spaStartDate;
  String subFolioTransfer;
  double tax;
  String tenanCode;
  String typeCode;
  String userId;
  String validMonth;
  String validYear;

  Transaction({
    required this.descriptionFree,
    required this.accountCode,
    required this.auditDate,
    required this.captainOrderId,
    required this.cardBankCode,
    required this.cardCharge,
    required this.cardHolder,
    required this.cardNumber,
    required this.cardTypeCode,
    required this.companyCode,
    required this.companyCode2,
    required this.currencyCode,
    required this.defaultCurrencyCode,
    required this.description,
    required this.discount,
    required this.discountTemp,
    required this.exchangeRate,
    required this.folioTransfer,
    required this.idLog,
    required this.inventoryCode,
    required this.isCompliment,
    required this.isFree,
    required this.isRemove,
    required this.logShiftId,
    required this.postingDate,
    required this.price,
    required this.priceOriginal,
    required this.pricePurchase,
    required this.productCode,
    required this.quantity,
    required this.quantityPrinted,
    required this.quantityPrintedCheck,
    required this.remark,
    required this.removeBy,
    required this.removeDate,
    required this.seatNumber,
    required this.service,
    required this.totalPrice,
    required this.shift,
    required this.spaEndDate,
    required this.spaRoomNumber,
    required this.spaStartDate,
    required this.subFolioTransfer,
    required this.tax,
    required this.tenanCode,
    required this.typeCode,
    required this.userId,
    required this.validMonth,
    required this.validYear,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      descriptionFree: json['DescriptionFree'] ?? '',
      accountCode: json['account_code'] ?? '',
      auditDate: json['audit_date'] ?? '',
      captainOrderId: json['captain_order_id'] ?? 0,
      cardBankCode: json['card_bank_code'] ?? '',
      cardCharge: Formats.parseDoubleWithLocale(json['card_charge'] ?? '0'),
      cardHolder: json['card_holder'] ?? '',
      cardNumber: json['card_number'] ?? '',
      cardTypeCode: json['card_type_code'] ?? '',
      companyCode: json['company_code'] ?? '',
      companyCode2: json['company_code2'] ?? '',
      currencyCode: json['currency_code'] ?? '',
      defaultCurrencyCode: json['default_currency_code'] ?? '',
      description: json['description'] ?? '',
      discount: Formats.parseDoubleWithLocale(json['discount'] ?? '0'),
      totalPrice: Formats.parseDoubleWithLocale(json['total_price'] ?? '0'),
      discountTemp: Formats.parseDoubleWithLocale(json['discount_temp'] ?? '0'),
      exchangeRate: Formats.parseDoubleWithLocale(json['exchange_rate'] ?? '0'),
      folioTransfer: json['folio_transfer'] ?? 0,
      idLog: json['id_log'] ?? 0,
      inventoryCode: json['inventory_code'] ?? '',
      isCompliment: json['is_compliment'] ?? '',
      isFree: json['is_free'] ?? '',
      isRemove: json['is_remove'] ?? '',
      logShiftId: json['log_shift_id'] ?? 0,
      postingDate: json['posting_date'] ?? '',
      price: Formats.parseDoubleWithLocale(json['price'] ?? '0'),
      priceOriginal:
          Formats.parseDoubleWithLocale(json['price_original'] ?? '0'),
      pricePurchase:
          Formats.parseDoubleWithLocale(json['price_purchase'] ?? '0'),
      productCode: json['product_code'] ?? '',
      quantity: Formats.parseDoubleWithLocale(json['quantity'] ?? '0'),
      quantityPrinted:
          Formats.parseDoubleWithLocale(json['quantity_printed'] ?? '0'),
      quantityPrintedCheck:
          Formats.parseDoubleWithLocale(json['quantity_printed_check'] ?? '0'),
      remark: json['remark'] ?? '',
      removeBy: json['remove_by'] ?? '',
      removeDate: json['remove_date'] ?? '',
      seatNumber: json['seat_number'] ?? 0,
      service: Formats.parseDoubleWithLocale(json['service'] ?? '0'),
      shift: json['shift'] ?? '',
      spaEndDate: json['spa_end_date'] ?? '',
      spaRoomNumber: json['spa_room_number'] ?? '',
      spaStartDate: json['spa_start_date'] ?? '',
      subFolioTransfer: json['sub_folio_transfer'] ?? '',
      tax: Formats.parseDoubleWithLocale(json['tax'] ?? '0'),
      tenanCode: json['tenan_code'] ?? '',
      typeCode: json['type_code'] ?? '',
      userId: json['user_id'] ?? '',
      validMonth: json['valid_month'] ?? '',
      validYear: json['valid_year'] ?? '',
    );
  }
}

class PaymentCaptainOrder {
  String descriptionFree;
  String accountCode;
  String auditDate;
  int captainOrderId;
  String cardBankCode;
  double cardCharge;
  String cardHolder;
  String cardNumber;
  String cardTypeCode;
  String companyCode;
  String companyCode2;
  String currencyCode;
  String defaultCurrencyCode;
  String description;
  double discount;
  double discountTemp;
  double exchangeRate;
  int folioTransfer;
  int idLog;
  String inventoryCode;
  String isCompliment;
  String isFree;
  String isRemove;
  int logShiftId;
  String postingDate;
  double price;
  double priceOriginal;
  double pricePurchase;
  String productCode;
  double quantity;
  double quantityPrinted;
  double quantityPrintedCheck;
  double totalPrice;
  String remark;
  String removeBy;
  String removeDate;
  int seatNumber;
  double service;
  String shift;
  String spaEndDate;
  String spaRoomNumber;
  String spaStartDate;
  String subFolioTransfer;
  double tax;
  String tenanCode;
  String typeCode;
  String userId;
  String validMonth;
  String validYear;

  PaymentCaptainOrder({
    required this.descriptionFree,
    required this.accountCode,
    required this.auditDate,
    required this.captainOrderId,
    required this.cardBankCode,
    required this.cardCharge,
    required this.cardHolder,
    required this.cardNumber,
    required this.cardTypeCode,
    required this.companyCode,
    required this.companyCode2,
    required this.currencyCode,
    required this.defaultCurrencyCode,
    required this.description,
    required this.discount,
    required this.discountTemp,
    required this.exchangeRate,
    required this.folioTransfer,
    required this.idLog,
    required this.inventoryCode,
    required this.isCompliment,
    required this.isFree,
    required this.isRemove,
    required this.logShiftId,
    required this.postingDate,
    required this.price,
    required this.priceOriginal,
    required this.pricePurchase,
    required this.productCode,
    required this.quantity,
    required this.quantityPrinted,
    required this.quantityPrintedCheck,
    required this.remark,
    required this.removeBy,
    required this.removeDate,
    required this.seatNumber,
    required this.service,
    required this.totalPrice,
    required this.shift,
    required this.spaEndDate,
    required this.spaRoomNumber,
    required this.spaStartDate,
    required this.subFolioTransfer,
    required this.tax,
    required this.tenanCode,
    required this.typeCode,
    required this.userId,
    required this.validMonth,
    required this.validYear,
  });

  factory PaymentCaptainOrder.fromJson(Map<String, dynamic> json) {
    return PaymentCaptainOrder(
      descriptionFree: json['DescriptionFree'] ?? '',
      accountCode: json['account_code'] ?? '',
      auditDate: json['audit_date'] ?? '',
      captainOrderId: json['captain_order_id'] ?? 0,
      cardBankCode: json['card_bank_code'] ?? '',
      cardCharge: Formats.parseDoubleWithLocale(json['card_charge'] ?? '0'),
      cardHolder: json['card_holder'] ?? '',
      cardNumber: json['card_number'] ?? '',
      cardTypeCode: json['card_type_code'] ?? '',
      companyCode: json['company_code'] ?? '',
      companyCode2: json['company_code2'] ?? '',
      currencyCode: json['currency_code'] ?? '',
      defaultCurrencyCode: json['default_currency_code'] ?? '',
      description: json['description'] ?? '',
      discount: Formats.parseDoubleWithLocale(json['discount'] ?? '0'),
      totalPrice: Formats.parseDoubleWithLocale(json['total_price'] ?? '0'),
      discountTemp: Formats.parseDoubleWithLocale(json['discount_temp'] ?? '0'),
      exchangeRate: Formats.parseDoubleWithLocale(json['exchange_rate'] ?? '0'),
      folioTransfer: json['folio_transfer'] ?? 0,
      idLog: json['id_log'] ?? 0,
      inventoryCode: json['inventory_code'] ?? '',
      isCompliment: json['is_compliment'] ?? '',
      isFree: json['is_free'] ?? '',
      isRemove: json['is_remove'] ?? '',
      logShiftId: json['log_shift_id'] ?? 0,
      postingDate: json['posting_date'] ?? '',
      price: Formats.parseDoubleWithLocale(json['price'] ?? '0'),
      priceOriginal:
          Formats.parseDoubleWithLocale(json['price_original'] ?? '0'),
      pricePurchase:
          Formats.parseDoubleWithLocale(json['price_purchase'] ?? '0'),
      productCode: json['product_code'] ?? '',
      quantity: Formats.parseDoubleWithLocale(json['quantity'] ?? '0'),
      quantityPrinted:
          Formats.parseDoubleWithLocale(json['quantity_printed'] ?? '0'),
      quantityPrintedCheck:
          Formats.parseDoubleWithLocale(json['quantity_printed_check'] ?? '0'),
      remark: json['remark'] ?? '',
      removeBy: json['remove_by'] ?? '',
      removeDate: json['remove_date'] ?? '',
      seatNumber: json['seat_number'] ?? 0,
      service: Formats.parseDoubleWithLocale(json['service'] ?? '0'),
      shift: json['shift'] ?? '',
      spaEndDate: json['spa_end_date'] ?? '',
      spaRoomNumber: json['spa_room_number'] ?? '',
      spaStartDate: json['spa_start_date'] ?? '',
      subFolioTransfer: json['sub_folio_transfer'] ?? '',
      tax: Formats.parseDoubleWithLocale(json['tax'] ?? '0'),
      tenanCode: json['tenan_code'] ?? '',
      typeCode: json['type_code'] ?? '',
      userId: json['user_id'] ?? '',
      validMonth: json['valid_month'] ?? '',
      validYear: json['valid_year'] ?? '',
    );
  }
}
