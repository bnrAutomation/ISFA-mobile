import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/product_category_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class ModifyProductsRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  final int storeId;

  ModifyProductsRepository(this.storeId);
  Future<List<ProductCategoryModel>> getCategoryList() async {
    final url =
        Uri.parse('${URLConstants.getCategoryList}/$userId/$compId/$storeId');

    final response = await get(url);
    if (response.statusCode == 200) {
      return categoryListfromRowJson(response.body);
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<bool> addInventoryQty(
      {required int catId, required int productId, required int qty}) async {
    final url = Uri.parse('${URLConstants.addInventory}/$userId');

    final body = {
      "storeId": storeId,
      "productId": productId,
      "categoryId": catId,
      "transUnit": qty
    };

    final response = await post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<bool> addSaleQty(
      {required int catId,
      required int productId,
      required int qty,
      required double price}) async {
    final url = Uri.parse('${URLConstants.saleProduct}/$userId');

    final body = {
      "storeId": storeId,
      "productId": productId,
      "categoryId": catId,
      "transUnit": qty,
      "price": price
    };

    final response = await post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }
}
