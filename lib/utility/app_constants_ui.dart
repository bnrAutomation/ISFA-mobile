import 'package:flutter/material.dart';

/// UI-related constants for the app
/// Centralized constants to improve maintainability
class AppConstantsUI {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color borderPrimary = Color(0xFFE0E0E0);
  static const Color borderSecondary = Color(0xFFBDBDBD);
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  
  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
  
  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 32.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Button Heights
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 40.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXL = 56.0;
  
  // Input Field Heights
  static const double inputHeightS = 32.0;
  static const double inputHeightM = 40.0;
  static const double inputHeightL = 48.0;
  static const double inputHeightXL = 56.0;
  
  // Card Dimensions
  static const double cardMinHeight = 80.0;
  static const double cardMaxHeight = 200.0;
  
  // List Item Heights
  static const double listItemHeightS = 48.0;
  static const double listItemHeightM = 56.0;
  static const double listItemHeightL = 64.0;
  static const double listItemHeightXL = 72.0;
  
  // App Bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 4.0;
  
  // Bottom Navigation
  static const double bottomNavHeight = 56.0;
  static const double bottomNavElevation = 8.0;
  
  // Floating Action Button
  static const double fabSize = 56.0;
  static const double fabMiniSize = 40.0;
  
  // Dialog
  static const double dialogMaxWidth = 400.0;
  static const double dialogMinWidth = 280.0;
  
  // Snackbar
  static const double snackbarHeight = 48.0;
  static const Duration snackbarDuration = Duration(seconds: 3);
  
  // Loading Indicators
  static const double loadingIndicatorSize = 24.0;
  static const double loadingIndicatorStrokeWidth = 2.0;
  
  // Image Dimensions
  static const double imageThumbnailSize = 64.0;
  static const double imageMediumSize = 128.0;
  static const double imageLargeSize = 256.0;
  
  // Avatar Sizes
  static const double avatarSizeS = 24.0;
  static const double avatarSizeM = 32.0;
  static const double avatarSizeL = 40.0;
  static const double avatarSizeXL = 48.0;
  static const double avatarSizeXXL = 64.0;
  
  // Progress Indicators
  static const double progressIndicatorHeight = 4.0;
  static const double progressIndicatorStrokeWidth = 2.0;
  
  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;
  
  // Chip
  static const double chipHeight = 32.0;
  static const double chipMinWidth = 48.0;
  
  // Badge
  static const double badgeSize = 16.0;
  static const double badgeOffset = 8.0;
  
  // Tooltip
  static const Duration tooltipDelay = Duration(milliseconds: 500);
  static const Duration tooltipDuration = Duration(seconds: 2);
  
  // Page Transitions
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  
  // Refresh Indicators
  static const double refreshIndicatorDisplacement = 40.0;
  static const double refreshIndicatorTriggerPullDistance = 100.0;
  
  // Scroll Physics
  static const double scrollPhysicsBounce = 0.5;
  static const double scrollPhysicsFriction = 0.5;
  
  // Grid Layout
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 1.0;
  static const double gridCrossAxisSpacing = 8.0;
  static const double gridMainAxisSpacing = 8.0;
  
  // List Layout
  static const double listItemSpacing = 8.0;
  static const double listPadding = 16.0;
  
  // Form Layout
  static const double formFieldSpacing = 16.0;
  static const double formSectionSpacing = 24.0;
  
  // Tab Layout
  static const double tabHeight = 48.0;
  static const double tabIndicatorHeight = 2.0;
  
  // Stepper
  static const double stepperHeight = 72.0;
  static const double stepperIconSize = 24.0;
  
  // Expansion Tile
  static const double expansionTileHeight = 48.0;
  
  // Data Table
  static const double dataTableRowHeight = 48.0;
  static const double dataTableHeaderHeight = 56.0;
  
  // Calendar
  static const double calendarDaySize = 40.0;
  static const double calendarWeekHeight = 48.0;
  
  // Time Picker
  static const double timePickerHeight = 216.0;
  
  // Date Picker
  static const double datePickerHeight = 216.0;
  
  // Slider
  static const double sliderHeight = 40.0;
  static const double sliderTrackHeight = 4.0;
  static const double sliderThumbRadius = 10.0;
  
  // Switch
  static const double switchWidth = 48.0;
  static const double switchHeight = 24.0;
  
  // Checkbox
  static const double checkboxSize = 20.0;
  
  // Radio
  static const double radioSize = 20.0;
  
  // Toggle Buttons
  static const double toggleButtonHeight = 40.0;
  static const double toggleButtonBorderWidth = 1.0;
  
  // Segmented Control
  static const double segmentedControlHeight = 40.0;
  
  // Search Bar
  static const double searchBarHeight = 48.0;
  
  // Filter Chips
  static const double filterChipHeight = 32.0;
  static const double filterChipSpacing = 8.0;
  
  // Action Chips
  static const double actionChipHeight = 32.0;
  static const double actionChipSpacing = 8.0;
  
  // Choice Chips
  static const double choiceChipHeight = 32.0;
  static const double choiceChipSpacing = 8.0;
  
  // Input Chips
  static const double inputChipHeight = 32.0;
  static const double inputChipSpacing = 8.0;
  
  // Assist Chips
  static const double assistChipHeight = 32.0;
  static const double assistChipSpacing = 8.0;
  
  // Suggestion Chips
  static const double suggestionChipHeight = 32.0;
  static const double suggestionChipSpacing = 8.0;
}
