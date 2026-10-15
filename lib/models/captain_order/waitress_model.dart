class Waitress {
  String? code;
  String? name;

  Waitress({this.code, this.name});

  Waitress.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = code;
    data['Name'] = name;
    return data;
  }
}
