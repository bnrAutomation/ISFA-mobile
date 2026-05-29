import 'package:flutter/material.dart';
import 'package:i_densfa/utility/app_constants.dart';

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
        colors: <Color>[ColorConstants.amber, ColorConstants.amberFade]),
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
              FittedBox(
                child: Text(
                  buttonText,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
