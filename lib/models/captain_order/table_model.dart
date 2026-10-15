class Tables {
  String? number;
  String? outletCode;

  Tables({this.number, this.outletCode});

  Tables.fromJson(Map<String, dynamic> json) {
    number = json['Number'];
    outletCode = json['OutletCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Number'] = number;
    data['OutletCode'] = outletCode;
    return data;
  }
}
