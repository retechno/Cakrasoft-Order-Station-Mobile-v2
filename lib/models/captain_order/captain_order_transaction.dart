class CaptainOrderTransaction {
  late int captainOrderId;
  num? priceOriginalForeign;
  num? subTotal;
  num? total;
  num? totalNett;
  String? accountCode;
  int? buy;
  String? companyCode1 = "";
  String? companyCode2 = "";
  String? companyName;
  String? currencyCode;
  String? defaultCurrencyCode;
  String? description;
  String? disableDiscount;
  num? discount;
  num? exchangeRate;
  int? free;
  int? iDLog;
  String? isFree;
  String? packageCode;
  num price = 0;
  num? priceOriginal;
  late String productCode;
  String? productName;
  int quantity = 0;
  String? remark;
  num? service;
  String? spaEndDate;
  String? spaRoomNumber;
  String? spaStartDate;
  num? tax;
  String? taxAndServiceCode;
  String? typeCode;
  String? categoryCode;

  CaptainOrderTransaction(
      {required this.captainOrderId,
      this.priceOriginalForeign,
      this.subTotal,
      this.total,
      this.totalNett,
      this.accountCode,
      this.buy,
      this.companyCode1 = "",
      this.companyCode2 = "",
      this.companyName,
      this.currencyCode,
      this.defaultCurrencyCode,
      this.description,
      this.disableDiscount,
      this.discount,
      this.exchangeRate,
      this.free,
      this.iDLog,
      this.isFree,
      this.packageCode,
      this.price = 0,
      this.priceOriginal,
      required this.productCode,
      this.productName,
      required this.quantity,
      this.remark,
      this.service,
      this.spaEndDate,
      this.spaRoomNumber = "",
      this.spaStartDate,
      this.tax,
      this.taxAndServiceCode,
      this.categoryCode,
      this.typeCode});

  CaptainOrderTransaction.fromJson(Map<String, dynamic> json) {
    captainOrderId = (json['CaptainOrderId'] as num?)?.toInt() ?? 0;
    priceOriginalForeign = json['PriceOriginalForeign'];
    subTotal = json['SubTotal'];
    total = json['Total'];
    totalNett = json['TotalNett'];
    accountCode = json['AccountCode'];
    buy = json['Buy'];
    companyCode2 = json['CompanyCode2'];
    companyCode1 = json['CompanyCode1'];
    companyName = json['CompanyName'];
    currencyCode = json['CurrencyCode'];
    defaultCurrencyCode = json['DefaultCurrencyCode'];
    description = json['Description'];
    disableDiscount = json['DisableDiscount'];
    discount = json['Discount'];
    exchangeRate = json['ExchangeRate'];
    free = json['Free'];
    iDLog = (json['IDLog'] as num?)?.toInt();
    isFree = json['IsFree'];
    packageCode = json['PackageCode'];
    price = json['Price'] ?? 0;
    priceOriginal = json['PriceOriginal'];
    productCode = json['ProductCode'] ?? "";
    productName = json['ProductName'];
    quantity = (json['Quantity'] as num?)?.toInt() ?? 0;
    remark = json['Remark'];
    service = json['Service'];
    spaEndDate = json['SpaEndDate'];
    spaRoomNumber = json['SpaRoomNumber'];
    spaStartDate = json['SpaStartDate'];
    tax = json['Tax'];
    taxAndServiceCode = json['TaxAndServiceCode'];
    typeCode = json['TypeCode'];
    categoryCode = json['CategoryCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PriceOriginalForeign'] = priceOriginalForeign;
    data['SubTotal'] = subTotal;
    data['Total'] = total;
    data['AccountCode'] = accountCode;
    data['Buy'] = buy;
    data['CompanyCode1'] = companyCode1;
    data['CompanyCode2'] = companyCode2;
    data['CompanyName'] = companyName;
    data['CurrencyCode'] = currencyCode;
    data['DefaultCurrencyCode'] = defaultCurrencyCode;
    data['Description'] = description;
    data['DisableDiscount'] = disableDiscount;
    data['Discount'] = discount;
    data['ExchangeRate'] = exchangeRate;
    data['Free'] = free;
    data['CaptainOrderId'] = captainOrderId;
    data['CaptainOrderTransactionID'] = iDLog;
    data['IsFree'] = isFree;
    data['PackageCode'] = packageCode;
    data['Price'] = price;
    data['PriceOriginal'] = priceOriginal;
    data['ProductCode'] = productCode;
    data['ProductName'] = productName;
    data['Quantity'] = quantity;
    data['Remark'] = remark;
    data['Service'] = service;
    data['SpaEndDate'] = spaEndDate;
    data['SpaRoomNumber'] = spaRoomNumber;
    data['SpaStartDate'] = spaStartDate;
    data['Tax'] = tax;
    data['TaxAndServiceCode'] = taxAndServiceCode;
    data['TypeCode'] = typeCode;
    data['CategoryCode'] = categoryCode;
    return data;
  }
}
