import 'dart:convert';

class InventoryDetailModel {
  InventoryDetailModel({
    required this.numberOfProduct,
    required this.numberOfSelling,
    required this.lastReciveDate,
    required this.productList,
    required this.openingBalance,
    required this.closingBalance,
  });

  int numberOfProduct;
  int numberOfSelling;
  DateTime lastReciveDate;
  double openingBalance;
  double closingBalance;
  List<InventoryProductDetailModel> productList;

  factory InventoryDetailModel.fromRawJson(String str) =>
      InventoryDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory InventoryDetailModel.fromJson(Map<String, dynamic> json) =>
      InventoryDetailModel(
        numberOfProduct: json["numberOfProduct"],
        numberOfSelling: json["numberOfSelling"],
        openingBalance: double.parse(json['openingBalance'] ?? "0.0"),
        closingBalance: double.parse(json['closingBalance'] ?? " 0.0"),
        lastReciveDate: DateTime.parse(json["lastReciveDate"]),
        productList: json["productList"] == null
            ? []
            : List<InventoryProductDetailModel>.from(json["productList"]
                .map((x) => InventoryProductDetailModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "numberOfProduct": numberOfProduct,
        "numberOfSelling": numberOfSelling,
        "openingBalance": openingBalance,
        "closingBalance": closingBalance,
        "lastReciveDate":
            "${lastReciveDate.year.toString().padLeft(4, '0')}-${lastReciveDate.month.toString().padLeft(2, '0')}-${lastReciveDate.day.toString().padLeft(2, '0')}",
        "productList": List<dynamic>.from(productList.map((x) => x.toJson())),
      };
}

class InventoryProductDetailModel {
  InventoryProductDetailModel({
    required this.productId,
    required this.categoryId,
    required this.categoryName,
    required this.productName,
    required this.price,
    this.stockBalance,
  });

  int productId;
  int categoryId;
  String categoryName;
  String productName;
  double price;
  int? stockBalance;

  factory InventoryProductDetailModel.fromRawJson(String str) =>
      InventoryProductDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory InventoryProductDetailModel.fromJson(Map<String, dynamic> json) =>
      InventoryProductDetailModel(
        productId: json["productId"],
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
        productName: json["productName"],
        price: json["price"] ?? 0.0,
        stockBalance: json["stockBalance"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "categoryId": categoryId,
        "categoryName": categoryName,
        "productName": productName,
        "price": price,
        "stockBalance": stockBalance,
      };
}
