class SubDepartment {
  String? code;
  String? name;

  SubDepartment({this.code, this.name});

  SubDepartment.fromJson(Map<String, dynamic> json) {
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
