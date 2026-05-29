import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Common UI components used across the app
/// Extracted to reduce code duplication and improve maintainability
class UIComponents {
  /// Create a standard card container
  static Widget createCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      margin: margin ?? EdgeInsets.all(16.w),
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 15.r),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Create a standard button
  static Widget createButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    double? width,
    double? height,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50.h,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, color: textColor ?? Colors.white),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  /// Create a standard outlined button
  static Widget createOutlinedButton({
    required String text,
    required VoidCallback onPressed,
    Color? borderColor,
    Color? textColor,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor ?? Colors.blue),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.blue,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor ?? Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  /// Create a standard text input field
  static Widget createTextInput({
    String? label,
    String? hint,
    String? initialValue,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    int? maxLines,
    bool obscureText = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
      ),
    );
  }

  /// Create a loading indicator
  static Widget createLoadingIndicator({
    String? message,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Colors.blue,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Create an error widget
  static Widget createErrorWidget({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 16.h),
            createButton(
              text: 'Retry',
              onPressed: onRetry,
              backgroundColor: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  /// Create an empty state widget
  static Widget createEmptyState({
    required String message,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            SizedBox(height: 16.h),
            action,
          ],
        ],
      ),
    );
  }

  /// Create a section header
  static Widget createSectionHeader({
    required String title,
    Widget? action,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  /// Create a list tile
  static Widget createListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool isThreeLine = false,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      isThreeLine: isThreeLine,
    );
  }

  /// Create a chip
  static Widget createChip({
    required String label,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onDeleted,
  }) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: textColor ?? Colors.white,
        ),
      ),
      backgroundColor: backgroundColor ?? Colors.blue,
      deleteIcon: onDeleted != null
          ? Icon(
              Icons.close,
              size: 16.sp,
              color: textColor ?? Colors.white,
            )
          : null,
      onDeleted: onDeleted,
    );
  }

  /// Create a divider with text
  static Widget createDividerWithText({
    required String text,
    Color? color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: color ?? Colors.grey[300],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: color ?? Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: color ?? Colors.grey[300],
          ),
        ),
      ],
    );
  }
}
