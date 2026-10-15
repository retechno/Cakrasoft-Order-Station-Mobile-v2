class Marketing {
  String? code;
  String? name;

  Marketing({this.code, this.name});

  Marketing.fromJson(Map<String, dynamic> json) {
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
