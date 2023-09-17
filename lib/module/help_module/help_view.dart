import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_densfa/module/ui/app_image_picker.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'bloc/help_bloc.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: BlocProvider(
          create: (context) => HelpBloc(),
          child: BlocConsumer<HelpBloc, HelpState>(
            listenWhen: (previous, current) =>
                current is HelpErrorState || current is HelpSuccessState,
            listener: (context, state) {
              if (state is HelpErrorState) {
                context.showSnackBarMessage(state.errorMessage);
              }
              if (state is HelpSuccessState) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (c) {
                      return CupertinoAlertDialog(
                        content:
                            Text(context.read<HelpBloc>().showDialogMessage),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(c);
                                Navigator.pop(context);
                              },
                              child: const Text("OK"))
                        ],
                      );
                    });
              }
            },
            builder: (context, state) {
              if (state is HelpLoadingState) {
                return SizedBox(
                  height: 1.sh,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final HelpBloc bloc = context.read();
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("Subject",
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 5),
                      Container(
                        width: 1.sw,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(8),
                              hintText: "Type your subject here..."),
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) =>
                              bloc.add(AddTitleHelpEvent(value)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Body",
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 5),
                      Container(
                        width: 1.sw,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 8, bottom: 8, top: 8, right: 8),
                              hintText: "Type your request here..."),
                          minLines: 2,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) =>
                              bloc.add(AddDescriptionHelpEvent(value)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                              backgroundImage: bloc.selectedImagePath == null
                                  ? null
                                  : FileImage(File(bloc.selectedImagePath!)),
                              backgroundColor: bloc.selectedImagePath == null
                                  ? Colors.grey
                                  : Colors.white,
                              radius: 50,
                              child: bloc.selectedImagePath == null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child:
                                          SvgPicture.asset(ImageConstants.scan),
                                    )
                                  : null),
                          const SizedBox(height: 10),
                          Expanded(
                            child: CustomMaterialButton(
                                buttonText: "Add Image",
                                onPressed: () {
                                  context.hideKeyboard();
                                  AppImagePicker(context, (image) {
                                    bloc.add(ClickImageHelpEvent(
                                        imagePath: image.path));
                                  });
                                }),
                          ),
                          const SizedBox(height: 5),
                          MaterialButton(
                            onPressed: () =>
                                bloc.add(RemoveSelectedImageHelpEvent()),
                            color: Colors.black,
                            textColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 18,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomMaterialButton(
                          buttonText: "Save",
                          onPressed: () {
                            context.hideKeyboard();
                            bloc.add(HelpSaveEvent());
                          }),
                      const SizedBox(height: 10),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
