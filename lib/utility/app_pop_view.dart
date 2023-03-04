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
}
