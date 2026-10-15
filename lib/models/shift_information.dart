class ShiftInformation {
  final int id;
  final String userId;
  final String shift;
  final String startDate;
  final String endDate;
  final String auditDate;
  final int openingBalance;
  final String remark;
  final String ipAddress;
  final String computerName;
  final String macAddress;
  final String systemCode;
  final String isOpen;

  ShiftInformation({
    this.id = 0,
    this.userId = "",
    this.shift = "",
    this.startDate = "0001-01-01T00:00:00Z",
    this.endDate = "0001-01-01T00:00:00Z",
    this.auditDate = "0001-01-01T00:00:00Z",
    this.openingBalance = 0,
    this.remark = "",
    this.ipAddress = "",
    this.computerName = "",
    this.macAddress = "",
    this.systemCode = "",
    this.isOpen = "",
  });

  factory ShiftInformation.fromJson(Map<String, dynamic> json) {
    return ShiftInformation(
      id: json['Id'] ?? 0,
      userId: json['UserId'] ?? "",
      shift: json['Shift'] ?? "",
      startDate: (json['StartDate'] ?? "0001-01-01T00:00:00Z"),
      endDate: (json['EndDate'] ?? "0001-01-01T00:00:00Z"),
      auditDate: (json['AuditDate'] ?? "0001-01-01T00:00:00Z"),
      openingBalance: json['OpeningBalance'] ?? 0,
      remark: json['Remark'] ?? "",
      ipAddress: json['IpAddress'] ?? "",
      computerName: json['ComputerName'] ?? "",
      macAddress: json['MacAddress'] ?? "",
      systemCode: json['SystemCode'] ?? "",
      isOpen: json['IsOpen'] ?? "",
    );
  }
}
