import 'package:intl/intl.dart';

extension DateTimeHelper on DateTime {
  String toStringFormat(String format) {
    return DateFormat(format).format(this);
  }
}
