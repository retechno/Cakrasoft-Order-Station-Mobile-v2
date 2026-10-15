class PaymentData {
  int captainOrderId;
  String accountCode;
  String accountName;
  String companyCode;
  String cardBankCode;
  String cardTypeCode;
  String cardNumber;
  String cardHolder;
  String validMonth;
  String validYear;
  int folioTransfer;
  String subFolioTransfer;
  double cardCharge;
  String roomNumber;
  num paymentAmount;

  PaymentData({
    required this.captainOrderId,
    required this.accountCode,
    this.accountName = "",
    this.companyCode = "",
    this.cardBankCode = "",
    this.cardTypeCode = "",
    this.cardNumber = "",
    this.cardHolder = "",
    this.validMonth = "",
    this.validYear = "",
    this.folioTransfer = 0,
    this.subFolioTransfer = "",
    this.cardCharge = 0,
    this.roomNumber = "",
    required this.paymentAmount,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      captainOrderId: json['captain_order_id'] ?? 0,
      accountCode: json['account_code'] ?? "",
      accountName: json['account_name'] ?? "",
      companyCode: json['company_code'] ?? "",
      cardBankCode: json['card_bank_code'] ?? "",
      cardTypeCode: json['card_type_code'] ?? "",
      cardNumber: json['card_number'] ?? "",
      cardHolder: json['card_holder'] ?? "",
      validMonth: json['valid_month'] ?? "",
      validYear: json['valid_year'] ?? "",
      folioTransfer: json['folio_transfer'] ?? 0,
      subFolioTransfer: json['sub_folio_transfer'] ?? "",
      cardCharge: json['card_charge'] ?? 0,
      roomNumber: json['room_number'] ?? "",
      paymentAmount: json['payment_amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['captain_order_id'] = captainOrderId;
    data['account_code'] = accountCode;
    data['account_name'] = accountName;
    data['company_code'] = companyCode;
    data['card_bank_code'] = cardBankCode;
    data['card_type_code'] = cardTypeCode;
    data['card_number'] = cardNumber;
    data['card_holder'] = cardHolder;
    data['valid_month'] = validMonth;
    data['valid_year'] = validYear;
    data['folio_transfer'] = folioTransfer;
    data['sub_folio_transfer'] = subFolioTransfer;
    data['card_charge'] = cardCharge;
    data['room_number'] = roomNumber;
    data['payment_amount'] = paymentAmount;
    return data;
  }
}
