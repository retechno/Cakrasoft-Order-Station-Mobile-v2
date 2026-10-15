class PaymentMethod {
  String accountCode;
  String name;
  int idSort;
  String subGroupCode;
  num exchangeRate;
  String currencyCode;
  String symbol;

  PaymentMethod({
    this.accountCode = "",
    this.name = "",
    this.idSort = 0,
    this.subGroupCode = "",
    this.exchangeRate = 1,
    this.currencyCode = "",
    this.symbol = "",
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      accountCode: json['account_code'] ?? "",
      name: json['name'] ?? "",
      idSort: json['id_sort'] ?? 0,
      subGroupCode: json['sub_group_code'] ?? "",
      exchangeRate: json['exchange_rate'] ?? 0,
      currencyCode: json['currency_code'] ?? "",
      symbol: json['symbol'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['account_code'] = accountCode;
    data['name'] = name;
    data['id_sort'] = idSort;
    data['sub_group_code'] = subGroupCode;
    data['exchange_rate'] = exchangeRate;
    data['currency_code'] = currencyCode;
    data['symbol'] = symbol;
    return data;
  }
}
