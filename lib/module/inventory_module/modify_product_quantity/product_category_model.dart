// To parse this JSON data, do
//
//     final productCategoryModel = productCategoryModelFromJson(jsonString);

import 'dart:convert';

List<ProductCategoryModel> categoryListfromRowJson(String str){

    final jsondata = json.decode(str);
    final list  =  jsondata["dataListIs"] ?? jsondata["dataList"];
   return List<ProductCategoryModel>.from(
     list
          .map((x) => ProductCategoryModel.fromJson(x)),
    );
}



List<SubCategoryModel> subCategoryListfromRowJson(String str) =>
    List<SubCategoryModel>.from(
      json.decode(str)
          .map((x) => SubCategoryModel.fromJson(x)),
    );

List<ProductList> productListfromRowJson(String str) =>
    List<ProductList>.from(
      json.decode(str)
          .map((x) => ProductList.fromJson(x)),
    );

class SubCategoryModel {
  SubCategoryModel({
    required this.subCategoryId,
    required this.categoryId,
    required this.subCategoryName,
    required this.productList,
  });
  late final int subCategoryId;
  late final int categoryId;
  late final String subCategoryName;
  List<ProductList> productList=[];
 
  
  SubCategoryModel.fromJson(Map<String, dynamic> json){
    subCategoryId = json['subCategoryId'];
    categoryId = json['categoryId'];
    subCategoryName = json['subCategoryName'];
    List<ProductList>.from(
            (json["productList"]??[]).map((x) => ProductList.fromJson(x)));
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['subCategoryId'] = subCategoryId;
    data['categoryId'] = categoryId;
    data['subCategoryName'] = subCategoryName;
    data["productList"]= List<dynamic>.from(productList.map((x) => x.toJson()));
    return data;
  }
}


class ProductCategoryModel {
  ProductCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.productList,
    required this.subCategoryList,
  });

  int categoryId;
  String categoryName;
  List<ProductList> productList=[];
  List<SubCategoryModel> subCategoryList=[];

  factory ProductCategoryModel.fromRawJson(String str) =>
      ProductCategoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) =>
      ProductCategoryModel(
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
        subCategoryList: List<SubCategoryModel>.from(
            (json["subCategoryList"]??[]).map((x) => ProductList.fromJson(x))),

        productList: List<ProductList>.from(
            (json["productList"]??[]).map((x) => ProductList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categoryId": categoryId,
        "categoryName": categoryName,
        "productList": List<dynamic>.from(productList.map((x) => x.toJson())),
        "subCategoryList": List<dynamic>.from(subCategoryList.map((x) => x.toJson())),
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
