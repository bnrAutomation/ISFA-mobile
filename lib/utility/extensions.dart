import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

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

extension TimeHelper on TimeOfDay {
  double toDouble() {
    return hour + minute / 60.0;
  }

  String toStringFormat(String format) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat(format).format(dateTime);
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
          r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&=])[A-Za-z\d@$!%*?&=]{16,}$")
      .hasMatch(this);

  bool urlValid() => RegExp(
          r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?')
      .hasMatch(this);
}

String encryptPassword(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
  //return password;
}

extension BuildContextHelper on BuildContext {
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void showSnackBarMessage(String message) {
    final msg = message.trim();
    final isSecurityBlock = msg.contains('Developer options are enabled') ||
        msg.contains('Mock location detected') ||
        msg.contains('GPS spoofing') ||
        msg.contains('Suspicious location change detected') ||
        msg.contains('Unrealistic movement detected') ||
        msg.contains('registered device');

    if (isSecurityBlock) {
      showDialog(
        context: this,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          title: const Row(
            children:  [
              Icon(Icons.warning_rounded, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Security alert',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(this, rootNavigator: true).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class CustomDateTime extends DateTime {
  CustomDateTime.fromDateTime(DateTime dateTime)
      : super(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
            dateTime.minute, dateTime.second, dateTime.millisecond);

  CustomDateTime(super.year, super.month, super.day,
      [super.hour, super.minute, super.second, super.millisecond]);

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
