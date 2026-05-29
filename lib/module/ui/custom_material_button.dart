import 'package:flutter/material.dart';
import 'package:i_densfa/utility/app_constants.dart';

class CustomMaterialButton extends StatelessWidget {
  final String buttonText;
  final Color textColor;
  final void Function() onPressed;
  final Gradient gradient;
  const CustomMaterialButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.textColor = Colors.white,
    this.gradient = const LinearGradient(
      colors: <Color>[
        ColorConstants.amber,
        Color(0XFFC92434),
        Color(0XFF003D5B),
        ColorConstants.amber,
      ],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      elevation: 2,
      //splashColor: Colors.black.withValues(alpha:0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
          alignment: Alignment.center,
          child: Text(
            buttonText,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
