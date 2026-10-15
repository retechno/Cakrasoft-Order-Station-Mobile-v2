class CaptainOrder {
  int? reservationNumber = 0;
  String? outletCode = "";
  String? outlet = "";
  String? tableNumber = "";
  String? waitressCode = "";
  String? customerCode = "";
  String? memberCode = "";
  String? titleCode = "";
  String? fullName = "";
  int? adult;
  int? child;
  String? documentNumber = "";
  String? remark = "";
  String? marketCode = "";
  String? companyCode = "";
  String? marketingCode = "";
  String? timeSegmentCode = "B";
  String? typeCode = "I";
  String? complimentTypeCode = "";
  String? complimentType = "";
  String? subDepartmentCode = "";
  String? isOpen = "-1";
  String? isPrinted = "-1";
  num? totalAmount = 0;
  int? idLog = 0;

  CaptainOrder(
      {this.reservationNumber = 0,
      this.outletCode = "",
      this.outlet = "",
      this.tableNumber = "",
      this.waitressCode = "",
      this.customerCode = "",
      this.memberCode = "",
      this.titleCode = "",
      this.fullName = "",
      this.adult,
      this.child,
      this.documentNumber = "",
      this.remark = "",
      this.marketCode = "",
      this.companyCode = "",
      this.marketingCode = "",
      this.timeSegmentCode = "B",
      this.typeCode = "D",
      this.complimentTypeCode = "",
      this.complimentType = "",
      this.subDepartmentCode = "",
      this.isOpen = "-1",
      this.isPrinted = "-1",
      this.idLog});

  CaptainOrder.fromJson(Map<String, dynamic> json) {
    reservationNumber = json['ReservationNumber'];
    outletCode = json['OutletCode'];
    outlet = json['Outlet'];
    tableNumber = json['TableNumber'];
    waitressCode = json['WaitressCode'];
    customerCode = json['CustomerCode'];
    memberCode = json['MemberCode'];
    titleCode = json['TitleCode'];
    fullName = json['FullName'];
    adult = json['Adult'];
    child = json['Child'];
    documentNumber = json['DocumentNumber'];
    remark = json['Remark'];
    marketCode = json['MarketCode'];
    companyCode = json['CompanyCode'];
    marketingCode = json['MarketingCode'];
    timeSegmentCode = json['TimeSegmentCode'];
    typeCode = json['TypeCode'];
    complimentTypeCode = json['ComplimentTypeCode'];
    complimentType = json['ComplimentType'];
    subDepartmentCode = json['SubDepartmentCode'];
    isOpen = json['IsOpen'];
    isPrinted = json['IsPrinted'];
    idLog = json['IdLog'];
    totalAmount = json['TotalAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ReservationNumber'] = reservationNumber;
    data['OutletCode'] = outletCode;
    data['Outlet'] = outlet;
    data['TableNumber'] = tableNumber;
    data['WaitressCode'] = waitressCode;
    data['CustomerCode'] = customerCode;
    data['MemberCode'] = memberCode;
    data['TitleCode'] = titleCode;
    data['FullName'] = fullName;
    data['Adult'] = adult;
    data['Child'] = child;
    data['DocumentNumber'] = documentNumber;
    data['Remark'] = remark;
    data['MarketCode'] = marketCode;
    data['CompanyCode'] = companyCode;
    data['MarketingCode'] = marketingCode;
    data['TimeSegmentCode'] = timeSegmentCode;
    data['TypeCode'] = typeCode;
    data['ComplimentTypeCode'] = complimentTypeCode;
    data['ComplimentType'] = complimentType;
    data['SubDepartmentCode'] = subDepartmentCode;
    data['IsOpen'] = isOpen;
    data['IsPrinted'] = isPrinted;
    data['IdLog'] = idLog;
    data['TotalAmount'] = totalAmount;
    return data;
  }
}
