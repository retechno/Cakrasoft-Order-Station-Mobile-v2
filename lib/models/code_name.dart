class CodeName {
  String code;
  String name;

  CodeName({
    this.code = "",
    this.name = "",
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CodeName && other.code == code && other.name == name;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  factory CodeName.fromJson(Map<String, dynamic> json) {
    return CodeName(
      code: json['code'] ?? "",
      name: json['name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}
