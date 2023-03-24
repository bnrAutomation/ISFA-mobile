import 'package:flutter/material.dart';

class LeavesData {
  final LeaveType leaveType;
  final String fromLeave;
  final String toLeave;
  final LeaveStatus approvalStatus;

  LeavesData(this.leaveType, this.fromLeave, this.toLeave, this.approvalStatus);
}

enum LeaveType { casual, sick, weekOff, other }

enum LeaveStatus { request, approve, reject }

extension LeaveTypeHelper on LeaveType {
  // ignore: unused_element
  int get rowVal {
    switch (this) {
      case LeaveType.casual:
        return 0;
      case LeaveType.sick:
        return 1;
      case LeaveType.weekOff:
        return 2;
      case LeaveType.other:
        return 4;
    }
  }

  // ignore: unused_element
  Color get refColor {
    switch (this) {
      case LeaveType.casual:
        return Colors.green;
      case LeaveType.sick:
        return Colors.red;
      case LeaveType.weekOff:
        return Colors.amber;
      case LeaveType.other:
        return Colors.black;
    }
  }
}
