final imageConstants = ImageConstants();
final statusConstants = StatusConstants();

class ImageConstants {
  final String logo = "assets/images/logo.png";
  final String triangle = "assets/images/triangle.svg";
  final String leavemask = "assets/images/leavemask.svg";
  final String doorOut = "assets/icons/door0ut.svg";
  final String sick = "assets/icons/sick.svg";
  final String walkman = "assets/icons/walkman.svg";
  final String sunumbrella = "assets/icons/sunumbrella.svg";
  final String line = "assets/icons/line.svg";
  final String navigator = "assets/icons/navigator.svg";
  final String box = "assets/icons/box.svg";
  final String campaign = "assets/icons/campaign.svg";
  final String feedback = "assets/icons/feedback.svg";
  final String scan = "assets/icons/scan.svg";

  final String progressImage = "assets/images/dummy_progress.png";
  final String casualLeaveBg = "assets/images/casual_leave_bg.png";
  final String sickLeaveBg = "assets/images/sick_leave_bg.png";
  final String weekoffLeave = "assets/images/weekoff_leave.png";
  final String otherLeave = "assets/images/other_leave.png";

  final String casualLeaveLogo = "assets/images/casual_leave_logo.png";
  final String sickLeaveLogo = "assets/images/sick_leave_logo.png";
  final String otherLeaveLogo = "assets/images/other_leave_logo.png";
  final String weekoffLeaveLogo = "assets/images/week_off_leave_logo.png";
}

class StatusConstants {
  final int requestLeave = 0;
  final int approveLeave = 1;
  final int rejectLeave = 2;

  final int casualTypeLeave = 0;
  final int sickTypeLeave = 1;
  final int weekOffTypeLeave = 2;
  final int otherTypeLeave = 3;
}
