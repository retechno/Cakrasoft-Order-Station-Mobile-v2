class Titles {
  String? code;
  String? name;

  Titles({this.code, this.name});

  factory Titles.fromJson(Map<String, dynamic> json) => Titles(code: json["Code"], name: json["Name"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = code;
    data['Name'] = name;
    return data;
  }
}
