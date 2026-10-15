// To parse this JSON data, do
//
//     final Outlets = OutletsFromJson(jsonString);

import 'dart:convert';

List<Outlets> OutletsFromJson(String str) => List<Outlets>.from(json.decode(str).map((x) => Outlets.fromJson(x)));

String OutletsToJson(List<Outlets> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Outlets {
  Outlets({required this.code, required this.name});

  String code;
  String name;

  factory Outlets.fromJson(Map<String, dynamic> json) => Outlets(code: json["Code"], name: json["Name"]);

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
      };
}
