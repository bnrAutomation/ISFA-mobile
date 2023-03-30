import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

class TabbarRepository {
  Future<SideMenuModel> getSideMenuDetails() async {
    final response = await get(Uri.parse(URLConstants.sidemenuDetails));
    final jsonRec = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return SideMenuModel.fromJson(jsonRec['data']);
    } else {
      throw jsonRec['message'];
    }
  }
}
