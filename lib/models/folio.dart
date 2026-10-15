class Folio {
  final String balance;
  final String fullName;
  final String billInstruction;
  final String isLock;
  final int number;
  final String roomNumber;
  final String typeCode;

  Folio({
    required this.balance,
    required this.fullName,
    required this.billInstruction,
    required this.isLock,
    required this.number,
    required this.roomNumber,
    required this.typeCode,
  });

  factory Folio.fromJson(Map<String, dynamic> json) {
    return Folio(
      balance: json['Balance'] ?? "",
      fullName: json['FullName'] ?? "",
      billInstruction: json['bill_instruction'] ?? "",
      isLock: json['is_lock'] ?? "",
      number: json['number'] ?? 0,
      roomNumber: json['room_number'] ?? "",
      typeCode: json['type_code'] ?? "",
    );
  }
}
