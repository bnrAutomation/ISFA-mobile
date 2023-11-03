import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPopup {
  static Future<T?> showAppBottomSheet<T>(
      {required BuildContext context, required Widget child}) {
    return showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      constraints: BoxConstraints(maxHeight: 1.sh - 20),
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 50,
                height: 3,
                color: Colors.grey,
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  static Widget dropDownMenu(
      {required List<String> options,
      required String placeholder,
      String? value,
      required void Function(String?)? onChanged,
      Widget suffixIcon = const Icon(Icons.keyboard_arrow_down)}) {
    return InputDecorator(
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          borderRadius: BorderRadius.circular(10),
          isExpanded: true,
          value: value,
          items: options
              .toSet()
              .map((value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: suffixIcon,
          hint: Text(
            placeholder,
            style: const TextStyle(color: Colors.grey),
          ),
        )),
      ),
    );
  }
}
