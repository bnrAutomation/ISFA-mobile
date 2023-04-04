// To parse this JSON data, do
//
//     final productCategoryModel = productCategoryModelFromJson(jsonString);

import 'dart:convert';

List<ProductCategoryModel> categoryListfromRowJson(String str) =>
    List<ProductCategoryModel>.from(
      json
          .decode(str)['dataListIs']
          .map((x) => ProductCategoryModel.fromJson(x)),
    );

class ProductCategoryModel {
  ProductCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.productList,
  });

  int categoryId;
  String categoryName;
  List<ProductList> productList;

  factory ProductCategoryModel.fromRawJson(String str) =>
      ProductCategoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) =>
      ProductCategoryModel(
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
        productList: List<ProductList>.from(
            json["productList"].map((x) => ProductList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categoryId": categoryId,
        "categoryName": categoryName,
        "productList": List<dynamic>.from(productList.map((x) => x.toJson())),
      };
}

class ProductList {
  ProductList({
    required this.productId,
    required this.categoryId,
    required this.productName,
    required this.price,
    this.stockBalance,
  });

  int productId;
  int categoryId;
  String productName;
  double price;
  int? stockBalance;

  factory ProductList.fromRawJson(String str) =>
      ProductList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
        productId: json["productId"],
        categoryId: json["categoryId"],
        productName: json["productName"],
        price: double.parse((json["price"] ?? 0.0).toString()),
        stockBalance: json["stockBalance"],
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "categoryId": categoryId,
        "productName": productName,
        "price": price,
        "stockBalance": stockBalance,
      };
}
