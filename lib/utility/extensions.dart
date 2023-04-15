import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeHelper on DateTime {
  String toStringFormat(String format) {
    return DateFormat(format).format(this);
  }
}

extension ColorExtension on String {
  toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
