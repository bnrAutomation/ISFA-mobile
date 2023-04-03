import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_densfa/module/promoter_module/feedback/bloc/feedback_bloc.dart';
import 'package:i_densfa/module/promoter_module/feedback/feedback_repository.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/app_constants.dart';

class FeedbackView extends StatelessWidget {
  final String storeName;
  const FeedbackView({super.key, required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: BlocProvider(
          create: (context) => FeedbackBloc(FeedbackRepository())
            ..add(FeedbackGetPurposesEvent()),
          child: BlocConsumer<FeedbackBloc, FeedbackState>(
            listenWhen: (previous, current) =>
                current is FeedbackErrorState ||
                current is FeedbackSuccessState,
            listener: (context, state) {
              if (state is FeedbackErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.errorMessage),
                ));
              }

              if (state is FeedbackSuccessState) {
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              if (state is FeedbackLoadingState) {
                return SizedBox(
                  height: 1.sh,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final FeedbackBloc bloc = context.read();
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Take Feedback",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(storeName,
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 5),
                      Text("Select Purpose",
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 5),
                      AppPopup.dropDownMenu(
                        options: bloc.purposes.map((e) => e.name).toList(),
                        placeholder: "Choose an option",
                        value: bloc.selectedPurpose?.name,
                        onChanged: (p0) {
                          if (p0 != null) {
                            bloc.add(SelectPurposeFeedbackEvent(p0));
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Text("Remarks",
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
                              hintText: "Type your remark here..."),
                          minLines: 2,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) =>
                              bloc.add(AddRemarkFeedbackEvent(value)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                              backgroundImage: bloc.selectedImage == null
                                  ? null
                                  : FileImage(File(bloc.selectedImage!.path)),
                              backgroundColor: bloc.selectedImage == null
                                  ? Colors.grey
                                  : Colors.white,
                              radius: 50,
                              child: bloc.selectedImage == null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child:
                                          SvgPicture.asset(ImageConstants.scan),
                                    )
                                  : null),
                          const SizedBox(height: 10),
                          Expanded(
                            child: CustomMaterialButton(
                                buttonText: "Click Image",
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  bloc.add(ClickImageFeedbackEvent());
                                }),
                          ),
                          const SizedBox(height: 5),
                          MaterialButton(
                            onPressed: () =>
                                bloc.add(RemoveSelectedImageFeedbackEvent()),
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
                          buttonText: "Save Feedback",
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            bloc.add(FeedbackSaveEvent());
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
