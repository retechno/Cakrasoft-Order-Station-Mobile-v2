class Order {
  num price = 0;
  String productName = "";
  String productCode = "";
  String? categoryCode;
  int quantity = 0;
  String? remark;

  Order(
      {this.price = 0,
      this.productName = "",
      this.productCode = "",
      this.categoryCode,
      this.quantity = 0,
      this.remark});

  Order.fromJson(Map<String, dynamic> json) {
    price = json['Price'] ?? 0;
    productCode = json['ProductCode'] ?? "";
    productName = json['ProductName'] ?? "";
    categoryCode = json['CategoryCode'];
    quantity = (json['Quantity'] as num?)?.toInt() ?? 0;
    remark = json['Remark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Price'] = price;
    data['ProductCode'] = productCode;
    data['ProductName'] = productName;
    data['CategoryCode'] = categoryCode;
    data['Quantity'] = quantity;
    data['Remark'] = remark;
    return data;
  }
}
