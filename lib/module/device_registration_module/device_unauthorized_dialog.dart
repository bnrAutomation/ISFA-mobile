import 'package:flutter/material.dart';

/// Shown when login is blocked because the device is not registered.
Future<void> showDeviceUnauthorizedDialog(
  BuildContext context, {
  required String username,
  String? message,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Row(
          children: [
            Icon(Icons.phonelink_erase_rounded, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Login Failed',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        content: Text(
          message ??
              'You can only login using your registered device.\n\n'
                  'Please use your authorized device or contact administrator.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
          // FilledButton(
          //   onPressed: () {
          //     Navigator.of(dialogContext).pop();
          //     context.pushNamed(
          //       AppPaths.deviceRegistration,
          //       extra: {'username': username},
          //     );
          //   },
          //   child: const Text('Request device change'),
          // ),
        ],
      );
    },
  );
}
