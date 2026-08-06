import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/utility/app_constants.dart';

class Background extends StatelessWidget {
  final bool showBackButton;
  const Background(this.showBackButton, {super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
       Positioned.fill(
            child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  ImageConstants.pinBack,
                  fit: BoxFit.cover,
                ))),
        Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.6))),

        showBackButton
            ? Positioned(
                top: 40,
                left: 10,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.6)),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Colors.orange,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
