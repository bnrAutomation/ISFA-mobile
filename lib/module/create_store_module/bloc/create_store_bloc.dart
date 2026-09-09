import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/create_store_module/create_store_model.dart';
import 'package:i_densfa/module/create_store_module/create_store_repository.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/base_bloc.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/services/%20region_mapper.dart';

part 'create_store_event.dart';
part 'create_store_state.dart';

class CreateStoreBloc extends BaseBloc<CreateStoreEvent, CreateStoreState> {
  final CreateStoreRepository repository;
  
  String? selectedStoreType;
  Position? currentLocation;
  List<String> storeTypes = ["New retailer"];

  CreateStoreBloc(this.repository) : super(CreateStoreInitial()) {
    on<CreateStoreSubmitEvent>(_onSubmit);
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<SelectLocationFromMapEvent>(_onSelectLocationFromMap);
    on<UpdateAddressFromMapEvent>(_onUpdateAddressFromMap);
    on<UpdateStoreTypeEvent>(_onUpdateStoreType);
    on<GenerateStoreCodeEvent>(_onGenerateStoreCode);
    on<ResetCreateStoreEvent>(_onReset);
    
    _loadStoreTypes();
  }

  Future<void> _loadStoreTypes() async {
    try {
      storeTypes = await repository.getStoreTypes();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading store types: $e');
      }
      storeTypes = [
        "New retailer"
        // 'Modern-Trade-Store-(MTS)',
        // 'Individual',
        // 'Promoter_store',
        // 'Dealer',
      ];
    }
  }

  Future<void> _onSubmit(
    CreateStoreSubmitEvent event,
    Emitter<CreateStoreState> emit,
  ) async {
    try {
      emit(CreateStoreLoading());
      final region = RegionMapper.getRegionName(currentLocation?.latitude??0.0,currentLocation?.longitude??0.0);
      final model = CreateStoreModel(
        storeName: event.storeName,
        storeCode: event.storeCode,
        gstNumber: event.gstNumber,
        phoneNo: event.phoneNo,
        contactName: event.contactName,
        storeType: event.storeType,
        address: event.address,
        city: event.city,
        region:region,
        state: event.state,
        location: event.location,
        zipcode: event.zipcode,
        latitude:currentLocation?.latitude,
        longitude:currentLocation?.longitude,
        campaignId: AppStorage().userDetail?.companyId.toString() ?? "-1",
        userId: AppStorage().userDetail?.id.toString()??"-1"
      );

      final response = await repository.createStore(model);
      
      emit(CreateStoreSuccess(response.message));
    } catch (e) {
      emit(CreateStoreError(e.toString()));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<CreateStoreState> emit,
  ) async {
    try {
      emit(CreateStoreLoading());
      
      final position = await Device().userPosition();
      currentLocation = position;
      
      // Get address details from coordinates using geocoding
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
      
        // Format complete address
        String fullAddress = _buildFullAddress(place);
        emit(AddressDetailsUpdated(
          latitude: position.latitude,
          longitude: position.longitude,
          address: fullAddress,
          city: place.locality ?? '',
          region: place.subAdministrativeArea ?? place.administrativeArea ?? '',
          state: place.administrativeArea ?? '',
          location: place.locality ?? '',
          zipcode: place.postalCode ?? '',
        ));
      } else {
        emit(CreateStoreError('Unable to get address details'));
      }
    } catch (e) {
      emit(CreateStoreError('Failed to get location: ${e.toString()}'));
    }
  }

  Future<void> _onSelectLocationFromMap(
    SelectLocationFromMapEvent event,
    Emitter<CreateStoreState> emit,
  ) async {
    // This will be handled by navigation to map picker
    // The map picker will return address details via UpdateAddressFromMapEvent
  }

  void _onUpdateAddressFromMap(
    UpdateAddressFromMapEvent event,
    Emitter<CreateStoreState> emit,
  ) {
    currentLocation = Position(
      latitude: event.latitude,
      longitude: event.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    
    emit(AddressDetailsUpdated(
      latitude: event.latitude,
      longitude: event.longitude,
      address: event.address,
      city: event.city,
      region: event.region,
      state: event.state,
      location: event.location,
      zipcode: event.zipcode,
    ));
  }

  String _buildFullAddress(Placemark place) {
    List<String> parts = [];
    
    if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
      parts.add(place.subThoroughfare!);
    }
    if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
      parts.add(place.thoroughfare!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      parts.add(place.postalCode!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      parts.add(place.country!);
    }
    
    return parts.join(', ');
  }

  void _onUpdateStoreType(
    UpdateStoreTypeEvent event,
    Emitter<CreateStoreState> emit,
  ) {
    selectedStoreType = event.storeType;
    emit(StoreTypeUpdated(event.storeType));
  }

  void _onGenerateStoreCode(
    GenerateStoreCodeEvent event,
    Emitter<CreateStoreState> emit,
  ) {
    // Generate 8-character unique store code
    // Format: 2 letters + 6 alphanumeric (e.g., SC1A2B3C)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Generate random letters for prefix
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final letter1 = letters[(timestamp % 26)];
    final letter2 = letters[((timestamp ~/ 26) % 26)];
    
    // Create store code: 2 letters + 6 mixed alphanumeric
    const alphanumeric = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String code = '$letter1$letter2';
    
    for (int i = 0; i < 7; i++) {
      final index = (timestamp + i * 7) % alphanumeric.length;
      code += alphanumeric[index];
    }
    
    if (kDebugMode) {
      debugPrint('Generated store code: $code');
    }
    emit(StoreCodeGenerated(code));
  }

  void _onReset(
    ResetCreateStoreEvent event,
    Emitter<CreateStoreState> emit,
  ) {
    selectedStoreType = "New Retailer";
    currentLocation = null;
    emit(CreateStoreInitial());
  }
}

