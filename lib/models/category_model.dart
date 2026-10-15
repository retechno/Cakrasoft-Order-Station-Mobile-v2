// To parse this JSON data, do
//
//     final Categories = CategoriesFromJson(jsonString);

import 'dart:convert';

List<Categories> CategoriesFromJson(String str) =>
    List<Categories>.from(json.decode(str).map((x) => Categories.fromJson(x)));

String CategoriesToJson(List<Categories> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Categories {
  Categories(
      {required this.code, required this.name, required this.outletCode, this.imageLink = "assets/images/image.png"});

  String code;
  String name;
  String outletCode;
  String imageLink = 'assets/images/image.png';

  factory Categories.fromJson(Map<String, dynamic> json) =>
      Categories(code: json["Code"], name: json["Name"], outletCode: json["OutletCode"], imageLink: json["ImageLink"]);

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "outletCode": outletCode,
        "imageLink": imageLink,
      };
}
