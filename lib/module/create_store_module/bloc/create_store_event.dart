part of 'create_store_bloc.dart';

@immutable
abstract class CreateStoreEvent {}

class CreateStoreSubmitEvent extends CreateStoreEvent {
  final String storeName;
  final String storeCode;
  final String? gstNumber;
  final String phoneNo;
  final String contactName;
  final String storeType;
  final String address;
  final String city;
  final String region;
  final String state;
  final String location;
  final String zipcode;

  CreateStoreSubmitEvent({
    required this.storeName,
    required this.storeCode,
    this.gstNumber,
    required this.phoneNo,
    required this.contactName,
    required this.storeType,
    required this.address,
    required this.city,
    required this.region,
    required this.state,
    required this.location,
    required this.zipcode,
  });
}

class ValidateGstNumberEvent extends CreateStoreEvent {
  final String gstNumber;

  ValidateGstNumberEvent(this.gstNumber);
}

class GenerateStoreCodeEvent extends CreateStoreEvent {}

class GetCurrentLocationEvent extends CreateStoreEvent {}

class SelectLocationFromMapEvent extends CreateStoreEvent {}

class UpdateAddressFromMapEvent extends CreateStoreEvent {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String region;
  final String state;
  final String location;
  final String zipcode;

  UpdateAddressFromMapEvent({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.region,
    required this.state,
    required this.location,
    required this.zipcode,
  });
}

class UpdateStoreTypeEvent extends CreateStoreEvent {
  final String storeType;

  UpdateStoreTypeEvent(this.storeType);
}

class ResetCreateStoreEvent extends CreateStoreEvent {}

