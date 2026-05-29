// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Color textColor;
  final Color buttonColor;
  final void Function() onPressed;
  final bool isLoading;
  final bool isSuccess;
  const CustomButton(
      {super.key,
      required this.buttonText,
      required this.onPressed,
      required this.isLoading,
      required this.isSuccess,
      this.textColor = Colors.black,
      this.buttonColor = Colors.amber});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeIn,
      width: isLoading || isSuccess ? 70.sw : 1.sw,
      child: isLoading || isSuccess
          ? buildSmallButton(context, isSuccess)
          : buildLargeButton(context),
    );
  }

  Widget buildLargeButton(BuildContext context) {
    return MaterialButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.w)),
        elevation: 2,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        minWidth: double.maxFinite,
        color: buttonColor,
        onPressed: onPressed,
        child: FittedBox(
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 14.sp, color: textColor),
          ),
        ));
  }

  Widget buildSmallButton(BuildContext context, bool isSuccess) {
    var color = isSuccess ? Colors.green : buttonColor;
    return InkWell(
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isSuccess
              ? const Icon(
                  Icons.done_outlined,
                  size: 40,
                  color: Colors.white,
                )
              : CircularProgressIndicator(
                  color: textColor,
                ),
        )),
      ),
    );
  }
}
