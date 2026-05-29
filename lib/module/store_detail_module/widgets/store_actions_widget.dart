import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/store_detail_module/bloc/store_detail_bloc.dart';

/// Store actions widget extracted from StoreDetailView
/// Displays action buttons like mark in/out, notes, feedback
class StoreActionsWidget extends StatelessWidget {
  final StoreDetailBloc bloc;

  const StoreActionsWidget({
    super.key,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
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
        children: [
          Text(
            'Store Actions',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Mark In/Out Button
        _buildMarkInOutButton(context),
        
        SizedBox(height: 16.h),
        
        // Notes Button
        _buildNotesButton(context),
        
        SizedBox(height: 16.h),
        
        // Feedback Button
        _buildFeedbackButton(context),
        
        SizedBox(height: 16.h),
        
        // Campaign Button
        _buildCampaignButton(context),
      ],
    );
  }

  Widget _buildMarkInOutButton(BuildContext context) {
    final isMarkedIn = bloc.beatPlanModel.markin;
    
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: () => _handleMarkInOut(context),
        icon: Icon(
          isMarkedIn ? Icons.logout : Icons.login,
          color: Colors.white,
        ),
        label: Text(
          isMarkedIn ? 'Mark Out' : 'Mark In',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isMarkedIn ? Colors.red : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton.icon(
        onPressed: () => _handleNotes(context),
        icon: const Icon(Icons.note_add),
        label: Text(
          'Add Notes',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton.icon(
        onPressed: () => _handleFeedback(context),
        icon: const Icon(Icons.feedback),
        label: Text(
          'Feedback',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.orange),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton.icon(
        onPressed: () => _handleCampaign(context),
        icon: const Icon(Icons.campaign),
        label: Text(
          'Campaign',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.purple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  void _handleMarkInOut(BuildContext context) {
    if (bloc.beatPlanModel.markin) {
      bloc.add(MarkOutStoreDetailEvent(context));
    } else {
      bloc.add(MarkInStoreDetailEvent(context));
    }
  }

  void _handleNotes(BuildContext context) {
    bloc.add(SaveNoteStoreDetailEvent());
  }

  void _handleFeedback(BuildContext context) {
    // Navigate to feedback view
    // This would be implemented based on your routing
  }

  void _handleCampaign(BuildContext context) {
    // Navigate to campaign view
    // This would be implemented based on your routing
  }
}
