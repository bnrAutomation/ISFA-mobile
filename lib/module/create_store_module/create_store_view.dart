import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/create_store_module/bloc/create_store_bloc.dart';
import 'package:i_densfa/module/create_store_module/map_location_picker_view.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

/// Add New Retailer View
/// Based on BRD: Add New Retailer Functionality in iSFA Mobile Application
class CreateStoreView extends StatefulWidget {
  const CreateStoreView({super.key});

  @override
  State<CreateStoreView> createState() => _CreateStoreViewState();
}

class _CreateStoreViewState extends State<CreateStoreView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // GlobalKeys for each field to enable scrolling
  final _storeNameKey = GlobalKey();
  final _storeCodeKey = GlobalKey();
  final _gstNumberKey = GlobalKey();
  final _contactPersonKey = GlobalKey();
  final _storeTypeKey = GlobalKey();
  final _contactNumberKey = GlobalKey();
  final _addressKey = GlobalKey();
  final _cityKey = GlobalKey();
  final _regionKey = GlobalKey();
  final _stateKey = GlobalKey();
  final _locationKey = GlobalKey();
  final _pincodeKey = GlobalKey();
  
  final _storeNameController = TextEditingController();
  final _storeCodeController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _stateController = TextEditingController();
  final _locationController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  String? _selectedStoreType;

  @override
  void dispose() {
    _scrollController.dispose();
    _storeNameController.dispose();
    _storeCodeController.dispose();
    _gstNumberController.dispose();
    _contactNumberController.dispose();
    _contactPersonController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _stateController.dispose();
    _locationController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Retailer',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: BlocConsumer<CreateStoreBloc, CreateStoreState>(
        listener: (context, state) {
          if (state is CreateStoreSuccess) {
            context.showSnackBarMessage('Retailer created successfully!');
            Navigator.pop(context, true);
          } else if (state is CreateStoreError) {
            context.showSnackBarMessage(state.message);
          } else if (state is StoreCodeGenerated) {
            // Handle generated store code
            setState(() {
              _storeCodeController.text = state.storeCode;
            });
            context.showSnackBarMessage('Store code generated: ${state.storeCode}');
          } else if (state is AddressDetailsUpdated) {
            // Auto-fill all address fields
            setState(() {
              _addressController.text = state.address;
              _cityController.text = state.city;
              _regionController.text = state.region;
              _stateController.text = state.state;
              _locationController.text = state.location;
              _pincodeController.text = state.zipcode;
            });
            context.showSnackBarMessage('Address details updated automatically!');
          }
        },
        builder: (context, state) {
          final bloc = context.read<CreateStoreBloc>();
          
          return SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildInfoCard(),
                  // SizedBox(height: 20.h),
                  
                  _buildSectionHeader('Basic Information'),
                  SizedBox(height: 12.h),
                  
                  // Store Name (Can be duplicate)
                  Container(
                    key: _storeNameKey,
                    child: _buildTextField(
                      controller: _storeNameController,
                      label: 'Store Name *',
                      hint: 'Enter store/retailer name',
                      icon: Icons.store,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter store name';
                        }
                        if (value.length < 3) {
                          return 'Store name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Store Code (Auto-generated with button)
                  Container(
                    key: _storeCodeKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _storeCodeController,
                            readOnly: true, // Make field read-only
                            decoration: InputDecoration(
                              labelText: 'Store Code *',
                              hintText: 'Click Generate button',
                              prefixIcon: const Icon(Icons.qr_code_2),
                              suffixIcon: Icon(
                                Icons.lock_outline,
                                size: 18.sp,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please generate store code';
                              }
                              /*if (value.length != 8) {
                                return 'Store code must be 8 characters';
                              }*/
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Generate Button
                        SizedBox(
                          height: 40, // Match the height of TextFormField
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<CreateStoreBloc>().add(GenerateStoreCodeEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: const EdgeInsets.all(8),
                            ),
                            icon: const Icon(Icons.refresh, color: Colors.white, size: 12),
                            label: Text(
                              'Generate',
                              style: GoogleFonts.poppins(
                               // fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  if(
                    AppStorage().userDetail?.configuration.requiredGstfromRetailer??false
                    )...[
                  // GST Number (Optional)
                  Container(
                    key: _gstNumberKey,
                    child: _buildTextField(
                      controller: _gstNumberController,
                      label: 'GST Number',
                      hint: 'Enter 15-digit GST number',
                      icon: Icons.receipt_long,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 15,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null; //'Please enter GST number';
                        }             //45YUIHG6754G5B2
                         // GST format: 22AAAAA0000A1Z5
                        final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
                        if (!gstRegex.hasMatch(value)) {
                            return 'Please enter valid GST number (15 characters)';
                        }
                    
                        return null;
                      },
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  ],
                  
                  // Contact Person
                  Container(
                    key: _contactPersonKey,
                    child: _buildTextField(
                      controller: _contactPersonController,
                      label: 'Contact Person *',
                      hint: 'Enter retailer contact person name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact person name';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Store Type Dropdown
                  Container(
                    key: _storeTypeKey,
                    child: _buildStoreTypeDropdown(bloc),
                  ),
                  
                  SizedBox(height: 24.h),
                  _buildSectionHeader('Contact Information'),
                  SizedBox(height: 12.h),
                  
                  // Contact Number (10 digits only)
                  Container(
                    key: _contactNumberKey,
                    child: _buildTextField(
                      controller: _contactNumberController,
                      label: 'Contact Number *',
                      hint: 'Enter 10-digit mobile number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact number';
                        }
                        if (value.length != 10) {
                          return 'Please enter valid 10-digit number';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  _buildSectionHeader('Address Details'),
                  SizedBox(height: 12.h),
                  
                  // Address (Read-only - filled from GPS/Map)
                  Container(
                    key: _addressKey,
                    child: _buildReadOnlyTextField(
                      controller: _addressController,
                      label: 'Address *',
                      hint: 'Select location to auto-fill',
                      icon: Icons.location_on,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select location to get address';
                        }
                        return null;
                      },
                      blocObject:bloc,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // City (Read-only - filled from GPS/Map)
                  Container(
                    key: _cityKey,
                    child: _buildReadOnlyTextField(
                      controller: _cityController,
                      label: 'City *',
                      hint: 'Auto-filled from location',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select location to get city';
                        }
                        return null;
                      },
                       blocObject:bloc,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // // Region (Read-only - filled from GPS/Map)
                  // Container(
                  //   key: _regionKey,
                  //   child: _buildReadOnlyTextField(
                  //     controller: _regionController,
                  //     label: 'Region *',
                  //     hint: 'Auto-filled from location',
                  //     icon: Icons.map,
                  //     validator: (value) {
                  //       if (value == null || value.isEmpty) {
                  //         return 'Please select location to get region';
                  //       }
                  //       return null;
                  //     },
                  //   ),
                  // ),
                  
                  // SizedBox(height: 16.h),
                  
                  // State (Read-only - filled from GPS/Map)
                  Container(
                    key: _stateKey,
                    child: _buildReadOnlyTextField(
                      controller: _stateController,
                      label: 'State *',
                      hint: 'Auto-filled from location',
                      icon: Icons.map_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select location to get state';
                        }
                        return null;
                      },
                       blocObject:bloc,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Location (Read-only - filled from GPS/Map)
                  Container(
                    key: _locationKey,
                    child: _buildReadOnlyTextField(
                      controller: _locationController,
                      label: 'Location *',
                      hint: 'Auto-filled from location',
                      icon: Icons.place,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select location';
                        }
                        return null;
                      },
                       blocObject:bloc,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Zipcode (Read-only - filled from GPS/Map)
                  Container(
                    key: _pincodeKey,
                    child: _buildReadOnlyTextField(
                      controller: _pincodeController,
                      label: 'Zipcode *',
                      hint: 'Auto-filled from location',
                      icon: Icons.pin_drop,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select location to get zipcode';
                        }
                        return null;
                      },
                       blocObject:bloc,
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Location Section (Optional)
                  _buildLocationSection(bloc, state),
                  
                  SizedBox(height: 32.h),
                  
                  // Submit Button
                  _buildSubmitButton(bloc, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildInfoCard() {
  //   return Container(
  //     padding: EdgeInsets.all(16.w),
  //     decoration: BoxDecoration(
  //       color: Colors.blue[50],
  //       borderRadius: BorderRadius.circular(10.r),
  //       border: Border.all(color: Colors.blue[200]!),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Icons.info, color: Colors.blue[700], size: 24.sp),
  //         SizedBox(width: 12.w),
  //         Expanded(
  //           child: Text(
  //             'Add new retailers directly from the field. All fields marked with * are mandatory.',
  //             style: GoogleFonts.poppins(
  //               fontSize: 12.sp,
  //               color: Colors.blue[900],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
    );
  }

  Widget _buildReadOnlyTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1, required CreateStoreBloc blocObject,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly:  blocObject.currentLocation==null?true:false,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: Icon(Icons.lock_outline, size: 18.sp, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
    );
  }



  Widget _buildStoreTypeDropdown(CreateStoreBloc bloc) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedStoreType,
      decoration: InputDecoration(
        labelText: 'Store Type *',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
      items: bloc.storeTypes
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedStoreType = value;
        });
        if (value != null) {
          bloc.add(UpdateStoreTypeEvent(value));
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a store type';
        }
        return null;
      },
    );
  }

  Widget _buildLocationSection(CreateStoreBloc bloc, CreateStoreState state) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.my_location, color: Colors.green[700]),
              SizedBox(width: 8.w),
              Text(
                'Select Location to Auto-Fill Address',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose location to automatically fill all address fields',
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey[700],
            ),
          ),
          if (bloc.currentLocation != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Location Captured\n'
                      'Lat: ${bloc.currentLocation!.latitude.toStringAsFixed(6)}, '
                      'Lng: ${bloc.currentLocation!.longitude.toStringAsFixed(6)}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12.h),
          
          // GPS Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state is CreateStoreLoading
                  ? null
                  : () {
                      bloc.add(GetCurrentLocationEvent());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(0, 45.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: const Icon(Icons.gps_fixed, color: Colors.white),
              label: Text(
                'Use Current GPS Location',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Map Selection Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state is CreateStoreLoading
                  ? null
                  : () async {
                      _openMapPicker(bloc);
                    },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, 45.h),
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: const Icon(Icons.map, color: Colors.green),
              label: Text(
                'Choose Location from Map',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker(CreateStoreBloc bloc) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerView(
          initialLatitude: bloc.currentLocation?.latitude,
          initialLongitude: bloc.currentLocation?.longitude,
        ),
      ),
    );

    if (result != null && mounted) {
      bloc.add(UpdateAddressFromMapEvent(
        latitude: result['latitude'],
        longitude: result['longitude'],
        address: result['address'] ?? '',
        city: result['city'] ?? '',
        region: result['region'] ?? '',
        state: result['state'] ?? '',
        location: result['location'] ?? '',
        zipcode: result['zipcode'] ?? '',
      ));
    }
  }

  Widget _buildSubmitButton(CreateStoreBloc bloc, CreateStoreState state) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: state is CreateStoreLoading
            ? null
            : () => _submitForm(bloc),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        icon: state is CreateStoreLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.add_business, color: Colors.white),
        label: Text(
          state is CreateStoreLoading ? 'Creating...' : 'Add New Retailer',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _submitForm(CreateStoreBloc bloc) {
    // Validate the form
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      _scrollToFirstError();
      return;
    }
    
    // If validation passes, submit the form
    bloc.add(CreateStoreSubmitEvent(
      storeName: _storeNameController.text.trim(),
      storeCode: _storeCodeController.text.trim(),
      gstNumber: _gstNumberController.text.trim().isEmpty 
          ? null 
          : _gstNumberController.text.trim(),
      phoneNo: _contactNumberController.text.trim(),
      contactName: _contactPersonController.text.trim(),
      storeType: _selectedStoreType!,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      region: _regionController.text.trim(),
      state: _stateController.text.trim(),
      location: _locationController.text.trim(),
      zipcode: _pincodeController.text.trim(),
    ));
  }

  void _scrollToFirstError() {
    // List of all field keys in order
    final fieldKeys = [
      _storeNameKey,
      _storeCodeKey,
      _gstNumberKey,
      _contactPersonKey,
      _storeTypeKey,
      _contactNumberKey,
      _addressKey,
      _cityKey,
      _regionKey,
      _stateKey,
      _locationKey,
      _pincodeKey,
    ];

    // Use postframe callback to ensure widgets are built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final key in fieldKeys) {
        final context = key.currentContext;
        if (context != null) {
          // Scroll to the first field found
          // This will typically be the first field with an error
          try {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: 0.2, // Position field 20% from top of screen
            );
            // Show a helpful message
            ScaffoldMessenger.of(this.context).showSnackBar(
             const SnackBar(
                content: Text('Please fill all required fields correctly'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
            break; // Exit after scrolling to the first field
          } catch (e) {
            // If scrolling fails, continue to next field
            continue;
          }
        }
      }
    });
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Retailer - Help',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Field Guide:',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              _buildHelpItem(
                'Store Name',
                'Official name of the retailer (can be duplicate)',
              ),
              _buildHelpItem(
                'Store Code',
                'Enter unique store identifier',
              ),
              _buildHelpItem(
                'GST Number',
                'Optional 15-digit GST number (Format: 22AAAAA0000A1Z5)',
              ),
              _buildHelpItem(
                'Contact Person',
                'Name of the store owner/manager',
              ),
              _buildHelpItem(
                'Store Type',
                'Select the category that best describes the store',
              ),
              _buildHelpItem(
                'Contact Number',
                'Must be 10 digits',
              ),
              _buildHelpItem(
                'Address',
                'Complete street address of the store',
              ),
              _buildHelpItem(
                'City',
                'City where the store is located',
              ),
              _buildHelpItem(
                'Region',
                'Region or area name (e.g., East Delhi)',
              ),
              _buildHelpItem(
                'State',
                'State name (e.g., Delhi)',
              ),
              _buildHelpItem(
                'Location',
                'Location identifier (e.g., New Delhi)',
              ),
              _buildHelpItem(
                'Zipcode',
                'Must be 6 digits',
              ),
              _buildHelpItem(
                'Location',
                'Optional GPS coordinates for accurate tracking',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
