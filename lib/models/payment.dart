class Payment {
  String? accountCode;
  num? amount;

  Payment({this.accountCode, this.amount});

  Payment.fromJson(Map<String, dynamic> json) {
    accountCode = json['AccountCode'] ?? "";
    amount = json['Total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AccountCode'] = accountCode;
    data['Total'] = amount;
    return data;
  }
}
