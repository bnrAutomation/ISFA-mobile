import 'package:flutter/material.dart';

class AppPopup {
  static Future<T?> showAppBottomSheet<T>(
      {required BuildContext context, required Widget child}) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 20),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          borderRadius: BorderRadius.circular(10),
          value: value,
          items: options
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
