import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/upload_selfie/bloc/upload_selfie_bloc.dart';

class UploadSelfieView extends StatelessWidget {
  const UploadSelfieView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocBuilder<UploadSelfieBloc, UploadSelfieState>(builder: (c, state) {
        if (state is UploadSelfieLoadingViewState) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final bloc = context.read<UploadSelfieBloc>();
          return SizedBox(
            height: 1.sh,
            width: 1.sw,
            child: CameraPreview(bloc.controller,
                child: overlayWidget(context, bloc)),
          );
        }
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xff0760F0), width: 2.w)),
          padding: const EdgeInsets.all(0),
          child: InkWell(
            onTap: context.read<UploadSelfieBloc>().clickPicture,
            child: const Icon(
              Icons.circle,
              color: Colors.white,
              size: 55,
            ),
          )),
    );
  }

  Widget overlayWidget(BuildContext context, UploadSelfieBloc bloc) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.keyboard_backspace,
                      color: Colors.white,
                    )),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: ColoredBox(
                    color: bloc.isFlashOn ? Colors.white : Colors.black12,
                    child: IconButton(
                        onPressed: () =>
                            bloc.add(UploadSelfieFlashChangeEvent()),
                        isSelected: bloc.isFlashOn,
                        selectedIcon: const Icon(
                          Icons.bolt_outlined,
                          color: Color(0xff0760F0),
                        ),
                        icon: const Icon(
                          Icons.bolt_outlined,
                          color: Colors.white,
                        )),
                  ),
                )
              ])
            ],
          ),
        ),
      ],
    );
  }
}
