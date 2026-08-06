import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/store_detail_module/bloc/store_detail_bloc.dart';

/// Store header widget extracted from StoreDetailView
/// Displays store image, name, and basic information
class StoreHeaderWidget extends StatelessWidget {
  final StoreDetailBloc bloc;

  const StoreHeaderWidget({
    super.key,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        child: Stack(
          children: [
            // Store Image
            _buildStoreImage(),
            
            // Gradient Overlay
            _buildGradientOverlay(),
            
            // Store Info
            _buildStoreInfo(),
            
            // Back Button
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreImage() {
    return CachedNetworkImage(
      imageUrl: bloc.beatPlanModel.storeImage1.isNotEmpty
          ? bloc.beatPlanModel.storeImage1
          : 'https://picsum.photos/200/300',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => CachedNetworkImage(
        imageUrl: 'https://media.istockphoto.com/id/912819604/vector/storefront-flat-design-e-commerce-icon.jpg?s=612x612&w=0&k=20&c=_x_QQJKHw_B9Z2HcbA2d1FH1U1JVaErOAp2ywgmmoTI=',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.store, size: 50, color: Colors.grey),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.store, size: 50, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Positioned(
      bottom: 20.h,
      left: 20.w,
      right: 20.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bloc.beatPlanModel.storeName,
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            bloc.beatPlanModel.address,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.phone,
                color: Colors.white,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                bloc.beatPlanModel.mobileNumber?.toString() ?? 'No phone available',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 50.h,
      left: 20.w,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
