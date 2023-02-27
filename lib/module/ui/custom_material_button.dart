import 'package:flutter/material.dart';

class CustomMaterialButton extends StatelessWidget {
  final String buttonText;
  final Function() onPressed;
  final Gradient gradient;
  const CustomMaterialButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.gradient = const LinearGradient(
      colors: <Color>[
        Color(0XFFFFBF00),
        Color(0XFFC92434),
        Color(0XFF003D5B),
        Color(0XFFFFBF00),

        // Colors.amber, Colors.black
      ],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      elevation: 2,
      //splashColor: Colors.black.withOpacity(0.5),
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
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
