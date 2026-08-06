import 'dart:convert';

class AnalyticsModel {
  final double target;
  final double achieved;
  final double percentage;
  final String kpiName;
  final int incentive;
  bool isExpand = false;
  List<Category> categories = [];
  List<ISPProductModel> ispProductList  = [];

  AnalyticsModel(
      {required this.target,
      required this.achieved,
      required this.percentage,
      required this.kpiName,
      required this.incentive});

  factory AnalyticsModel.fromRawJson(String str) =>
      AnalyticsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) => AnalyticsModel(
      target: (json["target"] ?? 0.0).toDouble(),
      achieved: (json["achieved"] ?? 0.0).toDouble(),
      percentage: (json["percentage"] ?? 0.0).toDouble(),
      kpiName: json["kpiName"],
      incentive: json["incentive"] ?? -1);

  Map<String, dynamic> toJson() => {
        "target": target,
        "achieved": achieved,
        "percentage": percentage,
        "kpiName": kpiName,
        "incentive": incentive
      };
}

class Product {
  Product({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.price,
    required this.quantity,
    required this.achieved,
    required this.target,
    required this.percentage,
  });
  late final int productId;
  late final String productName;
  late final String productCode;
  late final double price;
  late final int quantity;
  late final int achieved;
  late final int target;
  late final double percentage;

  factory Product.fromRawJson(String str) => Product.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productName = json['productName'];
    productCode = json['productCode'];
    price = json['price'];
    quantity = json['quantity'];
    achieved = json['achieved'];
    target = json['target'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['productId'] = productId;
    data['productName'] = productName;
    data['productCode'] = productCode;
    data['price'] = price;
    data['quantity'] = quantity;
    data['achieved'] = achieved;
    data['target'] = target;
    data['percentage'] = percentage;
    return data;
  }
}

class SubCategory {
  SubCategory({
    required this.subCategoryId,
    required this.subCategoryName,
    required this.achieved,
    required this.target,
    required this.percentage,
  });
  late final int subCategoryId;
  late final String subCategoryName;
  late final int achieved;
  late final int target;
  late final int percentage;
  bool isExpand = false;
  List<Product> products = [];

  factory SubCategory.fromRawJson(String str) =>
      SubCategory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  SubCategory.fromJson(Map<String, dynamic> json) {
    subCategoryId = json['subCategoryId'];
    subCategoryName = json['subCategoryName'];
    achieved = json['achieved'];
    // target = json['target'];
    // percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['subCategoryId'] = subCategoryId;
    data['subCategoryName'] = subCategoryName;
    data['achieved'] = achieved;
    // data['target'] = target;
    // data['percentage'] = percentage;
    return data;
  }
}

class Category {
  Category({
    required this.categoryId,
    required this.categoryName,
    required this.achieved,
    required this.target,
    required this.percentage,
  });
  late final int categoryId;
  late final String categoryName;
  late final int achieved;
  late final int target;
  late final int percentage;
  List<SubCategory> subcategories = [];
  bool isExpand = false;

  factory Category.fromRawJson(String str) =>
      Category.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    achieved = json['achieved'];
    // target = json['target'];
    // percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['categoryId'] = categoryId;
    data['categoryName'] = categoryName;
    data['achieved'] = achieved;
    // data['target'] = target;
    // data['percentage'] = percentage;
    return data;
  }
}

class ISPProductModel {
  ISPProductModel({
    required this.productName,
    required this.achieved,
    required this.target,
    required this.percentage,
    required this.kpiName,
  });
  late final String productName;
  late final double achieved;
  late final double target;
  late final double percentage;
  late final String kpiName;

  factory ISPProductModel.fromRawJson(String str) =>
      ISPProductModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  ISPProductModel.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    target = (json["target"] ?? 0.0).toDouble();
    achieved = (json["achieved"] ?? 0.0).toDouble();
    percentage = (json["percentage"] ?? 0.0).toDouble();
    kpiName = json['kpiName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['productName'] = productName;
    data['achieved'] = achieved;
    data['target'] = target;
    data['percentage'] = percentage;
    data['kpiName'] = kpiName;
    return data;
  }
}
