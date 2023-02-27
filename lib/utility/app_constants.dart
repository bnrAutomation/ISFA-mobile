final imageConstants = ImageConstants();
final statusConstants = StatusConstants();

class ImageConstants {
  final String logo = "assets/images/logo.png";
  final String triangle = "assets/images/triangle.svg";
  final String leavemask = "assets/images/leavemask.svg";
  final String inventoryMask = "assets/images/inventoryMask.svg";
  final String product = "assets/images/product.svg";

  final String filter = "assets/icons/filter.svg";
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
