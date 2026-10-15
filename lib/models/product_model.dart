// To parse this JSON data, do
//
//     final Products = ProductsFromJson(jsonString);

import 'dart:convert';

List<Products> ProductsFromJson(String str) => List<Products>.from(json.decode(str).map((x) => Products.fromJson(x)));

String ProductsToJson(List<Products> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Products {
  Products(
      {required this.code,
      required this.name,
      required this.categoryCode,
      required this.price,
      this.imageLink = "assets/images/image.png",
      required this.productCode,
      required this.productName});

  String code;
  String name;
  String productCode;
  String productName;
  String imageLink;
  String categoryCode;
  num price;

  factory Products.fromJson(Map<String, dynamic> json) => Products(
      code: json["Code"] ?? "",
      productCode: json["Code"] ?? "",
      productName: json["Name"] ?? "",
      name: json["Name"] ?? "",
      categoryCode: json["CategoryCode"] ?? "",
      imageLink: json["ImageLink"] ?? "assets/images/image.png",
      price: json["Price"] ?? 0);

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "categoryCode": categoryCode,
        "imageLink": imageLink,
        "price": price,
      };
}
