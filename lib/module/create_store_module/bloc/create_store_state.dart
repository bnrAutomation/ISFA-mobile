part of 'create_store_bloc.dart';

@immutable
abstract class CreateStoreState {}

class CreateStoreInitial extends CreateStoreState {}

class CreateStoreLoading extends CreateStoreState {}

class CreateStoreSuccess extends CreateStoreState {
  final String message;

  CreateStoreSuccess(this.message);
}

class CreateStoreError extends CreateStoreState {
  final String message;

  CreateStoreError(this.message);
}

class GstValidationSuccess extends CreateStoreState {
  final bool isUnique;
  final String message;

  GstValidationSuccess({required this.isUnique, required this.message});
}

class StoreCodeGenerated extends CreateStoreState {
  final String storeCode;

  StoreCodeGenerated(this.storeCode);
}

class LocationUpdated extends CreateStoreState {
  final double latitude;
  final double longitude;
  final String address;

  LocationUpdated({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class AddressDetailsUpdated extends CreateStoreState {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String region;
  final String state;
  final String location;
  final String zipcode;

  AddressDetailsUpdated({
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

class StoreTypeUpdated extends CreateStoreState {
  final String storeType;

  StoreTypeUpdated(this.storeType);
}

