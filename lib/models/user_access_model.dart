class UserAccess {
  String? userID;
  String? password;
  String? userAccessTypeCode;
  int? accessMode;
  bool? isPasswordEncrypted;

  UserAccess({this.userID, this.password, this.userAccessTypeCode, this.accessMode, this.isPasswordEncrypted});

  UserAccess.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    password = json['Password'];
    userAccessTypeCode = json['UserAccessTypeCode'];
    accessMode = json['AccessMode'];
    isPasswordEncrypted = json['IsPasswordEncrypted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserID'] = userID;
    data['Password'] = password;
    data['UserAccessTypeCode'] = userAccessTypeCode;
    data['AccessMode'] = accessMode;
    data['IsPasswordEncrypted'] = isPasswordEncrypted;
    return data;
  }
}

class UserAccessType {
  String form = "F";
  String report = "R";
  String special = "S";
  String keyLock = "K";
  String transactionTerminal = "E";
  String tableView = "V";
  String company = "C";
  String previewReport = "T";
  String reservation = "A";
  String memberVoucherGift = "M";
}

class UserSpecialAccess {
  int discount = 1;
  int overridePrice = 2;
  int modifyPrice = 3;
  int removeItem = 4;
  int cancelCaptainOrder = 5;
  int voidCheck = 6;
  int voidReservation = 7;
  int reduceQuantity = 8;
  int transferToDeskFolio = 9;
  int transferToMasterFolio = 10;
}
