import 'package:i_densfa/utility/app_storage.dart';

class MechanicVisitModel {
  final String location;
  final String mechanicContact;
  final String segment;
  final int storeId;
  final String retailerName;
  final String mechanicName;
  final bool isAlreadyMarkin;
  final bool markin;

  MechanicVisitModel({
    required this.location,
    required this.mechanicContact,
    required this.segment,
    required this.storeId,
    required this.retailerName,
    required this.mechanicName,
    required this.isAlreadyMarkin,
    required this.markin
  });

  factory MechanicVisitModel.fromJson(Map<String, dynamic> json) {
    return MechanicVisitModel(
      location: json['location']?.toString() ?? '',
      mechanicContact: json['mechanicContact']?.toString() ?? '',
      segment: json['segment']?.toString() ?? '',
      storeId: json['storeId'] is int
          ? json['storeId'] as int
          : int.tryParse(json['storeId']?.toString() ?? '') ?? 0,
      retailerName: json['retailerName']?.toString() ?? '',
      mechanicName: json['mechanicName']?.toString() ?? '',
      isAlreadyMarkin: json["alreadyMarkout"] ?? false,
      markin: json["markin"] ?? (AppStorage().markedInStoreId??-1) == (json['storeId'] is int
          ? json['storeId'] as int
          : int.tryParse(json['storeId']?.toString() ?? '') ?? 0),
    );
  }
}
