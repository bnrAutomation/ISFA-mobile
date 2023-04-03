import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class TabbarRepository {
  Future<SideMenuModel> getSideMenuDetails() async {
    final userId = AppStorage().userDetail!.id;
    final response =
        await get(Uri.parse('${URLConstants.sidemenuDetails}/$userId'));
    final jsonRec = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return SideMenuModel.fromJson(jsonRec['data']);
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }

    // final r = jsonEncode({
    //   "user_info": {
    //     "phone_no": null,
    //     "role": null,
    //     "user_name": "shubhamj@denave.com",
    //     "email": "shubhamj@denave.com"
    //   },
    //   "menu": [
    //     {
    //       "name": "Attendance",
    //       "icon": "https://example.com/icon_image/attendance.png",
    //       "isActive": true,
    //       "key": "attendance"
    //     },
    //     {
    //       "name": "Leave",
    //       "icon": "https://example.com/icon_image/leave.png",
    //       "isActive": true,
    //       "key": "leave"
    //     },
    //     {
    //       "name": "Promoter",
    //       "icon": "https://example.com/icon_image/promoter.png",
    //       "isActive": true,
    //       "key": "promoter"
    //     }
    //   ]
    // });

    // return SideMenuModel.fromRawJson(r);
  }
}
