import 'package:flutter/material.dart';

class CustomImageButton extends StatelessWidget {
  final String buttonText;
  final Function() onPressed;
  final Gradient gradient;
  final Widget image;
  const CustomImageButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.image,
    this.gradient = const LinearGradient(
      colors: <Color>[
        // Color(0XFFFFBF00),
        // Color(0XFFC92434),
        Color(0XFF003D5B),
        Color(0XFF278BBC),
        // Color(0XFFFFBF00),
      ],
    ),
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22.0),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 140),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image,
              const SizedBox(
                height: 5,
              ),
              Text(
                buttonText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
