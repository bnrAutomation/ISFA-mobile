
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DialogHelper {
  static showErrorMessage(
      BuildContext context, String? title, String? message, {Function? onOkayClick}) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            title: Text(title ?? ''),
            content: Text(message ?? ''),
            actions: <Widget>[
              TextButton(
                onPressed: () => onOkayClick==null ?context.pop(): onOkayClick.call(),
                child: const Text('OKAY'),
              ),
            ],
          );
        });
  }

  static showErrorMessageWithCallBack(
      BuildContext context, String? title, String? message,
      {required Function() onOkayClick}) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            title: Text(title ?? ''),
            content: Text(message ?? ''),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: onOkayClick,
                child: const Text('OKAY'),
              ),
            ],
          );
        });
  }

    static showErrorMessageWithBothCallBack(
      BuildContext context, String? title, String? message,
      {required Function() onOkayClick,required Function() onCancelClick}) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            title: Text(title ?? ''),
            content: Text(message ?? ''),
            actions: <Widget>[
              TextButton(
                onPressed: onCancelClick,
                
                //  () {
                //   context.pop();
                // },
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: onOkayClick,
                child: const Text('OKAY'),
              ),
            ],
          );
        });
  }

  static showSuccessMessage(
      BuildContext context, String? title, String? message) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            title: Text(
              title ?? '',
              style: const TextStyle(color: Colors.green),
            ),
            content: Text(message ?? ''),
            actions: <Widget>[
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('OKAY'),
              ),
            ],
          );
        });
  }
}
