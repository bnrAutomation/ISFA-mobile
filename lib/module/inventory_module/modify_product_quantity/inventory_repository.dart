import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/inventory_module/modify_product_quantity/product_category_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class ModifyProductsRepository {
  final userId = AppStorage().userDetail?.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  final int storeId;
  final client = CustomHttpBaseClient.instance;

  ModifyProductsRepository(this.storeId);
  Future<List<ProductCategoryModel>> getCategoryList() async {
    final url =  AppStorage().userDetail?.companyName.toLowerCase()==
      "organic india".toLowerCase()?
        Uri.parse(URLConstants.category):
        Uri.parse('${URLConstants.getCategoryList}/$userId/$compId/$storeId');
    if (kDebugMode) {
      debugPrint(AppStorage().userDetail?.companyName);
    }
    final response = await client.get(url);
    if (response.statusCode == 200) {
      return categoryListfromRowJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<SubCategoryModel>> getSubCategoryList(String categoryId) async {
    final url =
        Uri.parse('${URLConstants.subcategories}/$categoryId');
    final response = await client.get(url);
    if (response.statusCode == 200) {
      return subCategoryListfromRowJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

   Future<List<ProductList>> getProduct(int categoryId,int subcategoryid) async {
    final url =
        Uri.parse(URLConstants.productNames).replace(queryParameters: {"categoryId":categoryId.toString()
        ,"subCategoryId": subcategoryid.toString(),"storeId":storeId.toString()});
    final response = await client.get(url);
    if (response.statusCode == 200) {
      return productListfromRowJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> addInventoryQty(
      {required int catId,
      required int productId,
      required int qty,
      required double price}) async {


    final url = Uri.parse('${URLConstants.addInventory}/$userId');
    
    final body = {
      "storeId": storeId,
      "productId": productId,
      "categoryId": catId,
      "transUnit": qty,
      "totalPrice": "${qty * price}"
    };

    final response = await client.post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
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
      "price": price,
      "totalPrice": "${qty * price}"
    };

    final response = await client.post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }
}
