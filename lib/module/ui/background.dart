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
        // Positioned(
        //     top: 0,
        //     left: 0,
        //     child: Container(
        //       width: 0.3.sw >= 0.3.sh ? 0.3.sh : 0.3.sw,
        //       height: 0.3.sw >= 0.3.sh ? 0.3.sh : 0.3.sw,
        //       decoration: BoxDecoration(
        //         color: const Color(0XFFC92434),
        //         borderRadius: BorderRadius.only(
        //             bottomRight:
        //                 Radius.circular(0.5.sw >= 0.5.sh ? 0.5.sh : 0.5.sw)),
        //       ),
        //     )),
        // Positioned(
        //     top: 0,
        //     right: 0,
        //     child: Container(
        //       width: 0.5.sw >= 0.5.sh ? 0.5.sh : 0.5.sw,
        //       height: 0.5.sw >= 0.5.sh ? 0.5.sh : 0.5.sw,
        //       decoration: BoxDecoration(
        //         color: Theme.of(context).primaryColor,
        //         borderRadius: BorderRadius.only(
        //             bottomLeft:
        //                 Radius.circular(0.5.sw >= 0.5.sh ? 0.5.sh : 0.5.sw)),
        //       ),
        //     )),
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   child: SvgPicture.asset(
        //     ImageConstants.triangle,
        //   ),
        // ),
        // Positioned(
        //     bottom: 0,
        //     right: 0,
        //     child: Container(
        //       width: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
        //       height: 0.4.sw >= 0.4.sh ? 0.4.sh : 0.4.sw,
        //       decoration: BoxDecoration(
        //         color: ColorConstants.amber,
        //         borderRadius: BorderRadius.only(
        //             topLeft: Radius.circular(1.sw >= 1.sh ? 1.sh : 1.sw),
        //             bottomLeft: Radius.circular(1.sw >= 1.sh ? 1.sh : 1.sw)),
        //       ),
        //     )),

        Positioned.fill(
            child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  ImageConstants.pinBack,
                  fit: BoxFit.cover,
                ))),
        Positioned.fill(
            child: ColoredBox(color: Colors.black.withOpacity(0.6))),

        showBackButton
            ? Positioned(
                top: 40,
                left: 10,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.6)),
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
