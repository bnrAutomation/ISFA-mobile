enum LeaveStatus { pending, approved, rejected }

enum LeaveDayPart { full, firstHalf, secondHalf }

extension LeaveStatusHelper on LeaveStatus {
  LeaveStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }

  String toStr() {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }
}

extension LeaveDayPartHelper on LeaveDayPart {
  int get getId {
    switch (this) {
      case LeaveDayPart.full:
        return 1;
      case LeaveDayPart.firstHalf:
        return 2;
      case LeaveDayPart.secondHalf:
        return 3;
    }
  }

  String get name {
    switch (this) {
      case LeaveDayPart.full:
        return 'Full';
      case LeaveDayPart.firstHalf:
        return 'First half';
      case LeaveDayPart.secondHalf:
        return 'Second half';
    }
  }
}
