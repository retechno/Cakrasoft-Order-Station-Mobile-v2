import 'dart:convert';

import 'package:point_of_sales/models/user_access_model.dart';
import 'package:point_of_sales/utils/request.dart';

class SpecialAccessController {
  UserAccessType userAccessType = UserAccessType();
  UserSpecialAccess userSpecialAccess = UserSpecialAccess();

  Future specialAccess(String userId, String password, int accessMode) async {
    Map data = UserAccess(
            userID: userId,
            password: password,
            userAccessTypeCode: userAccessType.special,
            accessMode: accessMode,
            isPasswordEncrypted: false)
        .toJson();
    Request request = Request(url: 'CanUserAccess', body: jsonEncode(data));
    var res = false;
    var result = await request.post();
    if (result.statusCode == 200) {
      var body = jsonDecode(result.body);
      var res = body["Result"];
      return res == true;
    }

    return res;
  }

//API
}
