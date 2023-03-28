import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/product_category_model.dart';

class ModifyProductsRepository {
  Future<List<ProductCategoryModel>> getCategoryList() async {
    final url = Uri.parse(
        'https://devapps.denave.com:8448/iSFA/api/getCategoryList/1/1/1');

    final response = await get(url);
    if (response.statusCode == 200) {
      return categoryListfromRowJson(response.body);
    } else {
      throw json.decode(response.body)['message'];
    }
  }

  Future<bool> addInventoryQty(
      {required int catId, required int productId, required int qty}) async {
    final url =
        Uri.parse('https://devapps.denave.com:8448/iSFA/api/addInventory/1');

    final body = {
      "storeId": 1,
      "productId": productId,
      "categoryId": catId,
      "transUnit": qty
    };

    final response = await post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw json.decode(response.body)['message'];
    }
  }

  Future<bool> addSaleQty(
      {required int catId, required int productId, required int qty}) async {
    final url =
        Uri.parse('https://devapps.denave.com:8448/iSFA/api/saleProduct/1');

    final body = {
      "storeId": 1,
      "productId": productId,
      "categoryId": catId,
      "transUnit": qty
    };

    final response = await post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw json.decode(response.body)['message'];
    }
  }
}
