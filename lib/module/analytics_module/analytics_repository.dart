import 'dart:convert';

import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

import 'model/analytics_model.dart';

class AnalyticsRepository {
  final int userId;
  final client = CustomHttpBaseClient.instance;
  AnalyticsRepository(int? forUserId)
      : userId = forUserId ?? AppStorage().userDetail!.id;
 
 
  Future<List<AnalyticsModel>> getDetails(Map<String, String> queryParameters) async {
    final url = Uri.parse(
        '${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/$userId')
        .replace(
          queryParameters:queryParameters );

    final res = await client.get(url);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => AnalyticsModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(res);
    }
  }

 

    Future<List<Category>> getCategoryList(Map<String, String> queryParameters) async {
    final url = Uri.parse(
        '${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/$userId/categories')
        .replace(
          queryParameters:queryParameters);

    final res = await client.get(url);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => Category.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(res);
    }
  }


    Future<List<SubCategory>> getSubCategoryList(Map<String, String> queryParameters) async {
    final url = Uri.parse(
        '${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/$userId/subcategories')
        .replace(
          queryParameters:queryParameters);

    final res = await client.get(url);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SubCategory.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(res);
    }
  }

  Future<List<Product>> getProductList(Map<String, String> queryParameters) async {

    final url = Uri.parse(
        '${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/$userId/products')
        .replace(queryParameters:queryParameters);
    
    final res = await client.get(url);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => Product.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(res);
    }
  }
  


  Future<List<ISPProductModel>> getIspProductList() async {

    final url = Uri.parse(
        '${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/$userId/isp-drilldown');
        // .replace(queryParameters:queryParameters);
    
    final res = await client.get(url);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ISPProductModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(res);
    }
  }

     Future<List<ISPProductModel>> getPackSoldList(Map<String, String> queryParameters) async {

    final url = Uri.parse(
        '${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/$userId/packs-drilldown')
        .replace(queryParameters:queryParameters);
    
    final res = await client.get(url);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ISPProductModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(res);
    }
  }
}
