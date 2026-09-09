import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:i_densfa/module/create_store_module/create_store_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/handler.dart';

class CreateStoreRepository {
  final client = CustomHttpBaseClient.instance;
  final userId = AppStorage().userDetail?.id;
  final companyId = AppStorage().userDetail?.companyId;

  Future<CreateStoreResponse> createStore(CreateStoreModel model) async {
    // API endpoint: POST /iSFA/api/saveStore/{userId}
    // API expects multipart/form-data, not JSON
    if (kDebugMode) {
      debugPrint('Creating store for userId: $userId');
    }
    
    final uri = Uri.parse('${URLConstants.createStore}/$userId');
    
    // Create multipart request
    var request = http.MultipartRequest('POST', uri);
    
    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${AppStorage().authToken}',
    });
    
    // Add form fields
    request.fields['storeName'] = model.storeName;
    request.fields['storeCode'] = model.storeCode;
    request.fields['phoneNo'] = model.phoneNo;
    request.fields['contactName'] = model.contactName;
    request.fields['storeType'] = model.storeType;
    request.fields['address'] = model.address;
    request.fields['city'] = model.city;
    request.fields['region'] = model.region;
    request.fields['state'] = model.state;
    request.fields['location'] = model.location;
    request.fields['zipcode'] = model.zipcode;
    request.fields['campaignId'] = model.campaignId;
    request.fields['activity'] = 'store';
    request.fields['userId'] = model.userId;
    
    // Add optional fields
    if (model.gstNumber != null && model.gstNumber!.isNotEmpty) {
      request.fields['gst'] = model.gstNumber!;
    }
    
    if (model.latitude != null) {
      request.fields['latitude'] = model.latitude.toString();
    }
    
    if (model.longitude != null) {
      request.fields['longitude'] = model.longitude.toString();
    }
    
    // Debug print
    if (kDebugMode) {
      debugPrint('Form fields: ${request.fields}');
    }
    
    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (kDebugMode) {
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreateStoreResponse.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<Map<String, dynamic>> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    // This would typically call a geocoding service
    // For now, returning coordinates
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}',
    };
  }

  Future<List<String>> getStoreTypes() async {
    // Predefined store types as per requirements
    return [
      "New retailer"
      // 'Modern-Trade-Store-(MTS)',
      // 'Individual',
      // 'Promoter_store',
      // 'Dealer',
    ];
  }
}

