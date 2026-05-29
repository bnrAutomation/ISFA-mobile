import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/extensions.dart';

/// Map Location Picker Screen
/// Allows user to select location by moving map camera
/// Returns decoded address details with lat/long
class MapLocationPickerView extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapLocationPickerView({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapLocationPickerView> createState() => _MapLocationPickerViewState();
}

class SearchResultItem {
  final String name;
  final String formattedAddress;
  final LatLng coordinates;

  SearchResultItem({
    required this.name,
    required this.formattedAddress,
    required this.coordinates,
  });
}

class _MapLocationPickerViewState extends State<MapLocationPickerView> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  LatLng? _currentPosition;
  String _currentAddress = 'Loading...';
  bool _isLoadingAddress = false;
  List<SearchResultItem> _searchResults = [];
  bool _isSearchingLocation = false;
  String _searchErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.initialLatitude != null && widget.initialLongitude != null) {
        _currentPosition = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      } else {
        final position = await Device().userPosition();
        _currentPosition = LatLng(position.latitude, position.longitude);
      }
      setState(() {});
      _getAddressFromLatLng(_currentPosition!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting location: $e');
      }
      // Default to Delhi if location fails
      setState(() {
        _currentPosition = const LatLng(28.6139, 77.2090);
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
      _currentAddress = 'Getting address...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        setState(() {
          _currentAddress = _formatAddress(place);
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting address: $e');
      }
      setState(() {
        _currentAddress = 'Unable to get address';
        _isLoadingAddress = false;
      });
    }
  }

  String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
      addressParts.add(place.subThoroughfare!);
    }
    if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
      addressParts.add(place.thoroughfare!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      addressParts.add(place.postalCode!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.join(', ');
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer if it exists
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Clear results and error immediately if search is empty
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchErrorMessage = '';
        _isSearchingLocation = false;
      });
      return;
    }
    
    // Start new timer - search after 500ms of no typing
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(value.trim());
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchErrorMessage = '';
        _isSearchingLocation = false;
      });
      return;
    }

    setState(() {
      _isSearchingLocation = true;
      _searchErrorMessage = '';
    });

    try {
      final results = await _searchWithNominatim(query);
      
      setState(() {
        _searchResults = results;
        _searchErrorMessage = results.isEmpty 
            ? 'No locations found. Try different keywords.'
            : '';
        _isSearchingLocation = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching location: $e');
      }
      
      String errorMessage = 'Search failed. ';
      if (e.toString().contains('network') || 
          e.toString().contains('connection') ||
          e.toString().contains('SocketException')) {
        errorMessage += 'Check your internet connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage += 'Request timed out. Try again.';
      } else {
        errorMessage += 'Try another search term.';
      }
      
      setState(() {
        _searchResults = [];
        _searchErrorMessage = errorMessage;
        _isSearchingLocation = false;
      });
    }
  }

  Future<List<SearchResultItem>> _searchWithNominatim(String query) async {
    final url = 'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&addressdetails=1'
        '&limit=5';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'iSFA-Mobile-App/1.0', // Required by Nominatim
        'Accept-Language': 'en', // Get results in English
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      
      if (results.isEmpty) {
        return [];
      }
      
      return results.map((item) {
        final address = item['address'] ?? {};
        String name = item['name'] ?? 
                      address['shop'] ?? 
                      address['building'] ?? 
                      address['road'] ?? 
                      address['suburb'] ?? 
                      address['city'] ?? 
                      address['town'] ?? 
                      address['village'] ?? 
                      'Unknown Location';
        
        return SearchResultItem(
          name: name,
          formattedAddress: item['display_name'],
          coordinates: LatLng(
            double.parse(item['lat']),
            double.parse(item['lon']),
          ),
        );
      }).toList();
    } else {
      throw 'Failed to load places: ${response.statusCode}';
    }
  }

  Future<void> _moveToLocation(SearchResultItem searchResult) async {
    final controller = await _controller.future;
    
    // Animate camera with zoom
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: searchResult.coordinates,
          zoom: 16, // Closer zoom for better view
        ),
      ),
    );
    
    setState(() {
      _currentPosition = searchResult.coordinates;
      _searchResults = [];
      _searchController.clear();
      _searchErrorMessage = '';
    });
    
    _getAddressFromLatLng(searchResult.coordinates);
  }

  void _onCameraMove(CameraPosition position) {
    _currentPosition = position.target;
  }

  void _onCameraIdle() {
    if (_currentPosition != null) {
      _getAddressFromLatLng(_currentPosition!);
    }
  }

  Future<void> _confirmLocation() async {
    if (_currentPosition == null) {
      context.showSnackBarMessage('Please select a location');
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        
        // Return address details
        final result = {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'address': _formatAddress(place),
          'city': place.locality ?? '',
          'region': place.subAdministrativeArea ?? place.administrativeArea ?? '',
          'state': place.administrativeArea ?? '',
          'location': place.locality ?? '',
          'zipcode': place.postalCode ?? '',
        };
        
        if (mounted) {
          Navigator.pop(context, result);
        }
      }
    } catch (e) {
      context.showSnackBarMessage('Error getting address details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Location',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: _buildSearchBar(),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),

          // Center Pin
          Center(
            child: Icon(
              Icons.location_pin,
              size: 50.sp,
              color: Colors.red,
            ),
          ),

          // Search Results or Error Message
          if (_searchResults.isNotEmpty || _searchErrorMessage.isNotEmpty) 
            _buildSearchResults(),

          // Address Display Card - Positioned at bottom above confirm button
          if (_searchResults.isEmpty && _searchErrorMessage.isEmpty)
            Positioned(
              bottom: 90.h,
              left: 16.w,
              right: 16.w,
              child: _buildAddressCard(),
            ),

          // Confirm Button
          Positioned(
            bottom: 20.h,
            left: 20.w,
            right: 20.w,
            child: _buildConfirmButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Theme.of(context).primaryColor,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search location...',
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: _isSearchingLocation
              ? Padding(
                  padding: EdgeInsets.all(12.w),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        _debounce?.cancel();
                        setState(() {
                          _searchResults = [];
                          _searchErrorMessage = '';
                          _isSearchingLocation = false;
                        });
                      },
                    )
                  : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // Show empty state or error message
    if (_searchResults.isEmpty && _searchErrorMessage.isNotEmpty) {
      return Positioned(
        top: 16.h,
        left: 16.w,
        right: 16.w,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _searchErrorMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Positioned(
      top: 16.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 300.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _searchResults.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final searchResult = _searchResults[index];
            
            return ListTile(
              leading: Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 24.sp),
              title: Text(
                searchResult.name,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                searchResult.formattedAddress,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
              onTap: () => _moveToLocation(searchResult),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.place, color: Colors.blue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Selected Location',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (_isLoadingAddress)
            const CircularProgressIndicator()
          else
            Text(
              _currentAddress,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: _isLoadingAddress ? null : _confirmLocation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text(
          'Confirm Location',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

