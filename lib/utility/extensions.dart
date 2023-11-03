import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeHelper on DateTime {
  /// Return a string representing [date] formatted according to our locale
  /// and internal format.
  String toStringFormat(String format) {
    return DateFormat(format).format(this);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension Amount on double {
  String toformat() {
    var price = this;
    return "₹ ${price.toStringAsFixed(2)}";
  }
}

extension Helper on String {
  String capitalizeFirst() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  Color toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  bool passwordValid() => RegExp(
          r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$")
      .hasMatch(this);
}

extension BuildContextHelper on BuildContext {
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void showSnackBarMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}

class CustomDateTime extends DateTime {
  CustomDateTime.fromDateTime(DateTime dateTime)
      : super(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
            dateTime.minute, dateTime.second, dateTime.millisecond);

  CustomDateTime(int year, int month, int day,
      [int hour = 0, int minute = 0, int second = 0, int millisecond = 0])
      : super(year, month, day, hour, minute, second, millisecond);

  factory CustomDateTime.fromList(List<int> dateTimeData) {
    if (dateTimeData.length < 3) {
      final now = DateTime.now();
      return CustomDateTime(now.year, now.month, now.day);
    }
    final year = dateTimeData[0];
    final month = dateTimeData[1];
    final day = dateTimeData[2];

    // Check if there is enough data to create a DateTime with time components
    if (dateTimeData.length >= 6) {
      final hour = dateTimeData[3];
      final minute = dateTimeData[4];
      final second = dateTimeData[5];

      // Check if milliseconds are provided
      if (dateTimeData.length >= 7) {
        final millisecond = dateTimeData[6];
        return CustomDateTime(
            year, month, day, hour, minute, second, millisecond);
      } else {
        return CustomDateTime(year, month, day, hour, minute, second);
      }
    }

    // If no time components are provided, return a DateTime with the date only
    return CustomDateTime(year, month, day);
  }

  factory CustomDateTime.fromAny(dynamic dateTimeData) {
    if (dateTimeData is List<int>) {
      return CustomDateTime.fromList(dateTimeData);
    } else if (dateTimeData is DateTime) {
      return CustomDateTime.fromDateTime(dateTimeData);
    } else if (dateTimeData is String) {
      final date = DateTime.tryParse(dateTimeData) ?? DateTime.now();
      return CustomDateTime.fromDateTime(date);
    } else {
      final date = DateTime(1970);
      return CustomDateTime.fromDateTime(date);
    }
  }
}
