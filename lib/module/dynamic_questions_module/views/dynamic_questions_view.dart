import 'dart:io';
import 'package:custom_rating_bar/custom_rating_bar.dart' show RatingBar;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/module/ui/speech_input_widgets.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/continuous_location_service.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/image_compression_helper.dart';
import 'package:image_picker/image_picker.dart';
import '../model.dart';
import 'dart:ui' as ui;

class DynamicQuestionsView extends StatefulWidget {
  final void Function(String question, String answer,int questionOrder)? onAnswerUpdate;
  final void Function(
      String questionUuid, String path, bool isIssue, int index)? onImageUpload;
  final List<QuestionModel> questions;
  final String name;
  final requiredMultiImageInCampaign =
      AppStorage().userDetail?.configuration.requiredMultiImageInCampaign ??
          false;
  DynamicQuestionsView(
      {super.key,
      required this.questions,
      this.onAnswerUpdate,
      this.onImageUpload,
      this.name = "dynamic"});

  @override
  State<DynamicQuestionsView> createState() => _DynamicQuestionsViewState();
}

class _DynamicQuestionsViewState extends State<DynamicQuestionsView>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  double _savedPosition = 0.0;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      _savedPosition = _scrollController.position.pixels;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Required asterisk immediately after question text (avoids [Expanded] pushing * to row end).
  Widget _questionTitleWithRequired(
    BuildContext context,
    String questionText,
    bool isRequired, {
    TextStyle? baseStyle,
  }) {
    final style = baseStyle ?? Theme.of(context).textTheme.titleMedium;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: questionText),
          if (isRequired)
            const TextSpan(
              text: '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FocusManager.instance.primaryFocus?.unfocus();
      _scrollController.jumpTo(_savedPosition);
    }
    if (kDebugMode) {
      debugPrint(state.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!["isp", "osmm","order sheet"].contains(widget.name.toLowerCase())) {
      bool closeKeypad = widget.questions.any((element) => element.isfromImage);
      if (!closeKeypad) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(FocusNode());
        });
      }
    }
    return Theme(
      data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
              titleMedium: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: Colors.black))),
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: widget.questions.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final question = widget.questions[index];
          final textController = question.textEditingController;
          _syncControllerText(textController, question.answer);
          final issuestextController = question.issuesTextEditingController;
          _syncControllerText(issuestextController, question.issuesRemark);
          switch (question.questionType) {
            case QuestionInputType.singleLineText:
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: _questionTitleWithRequired(
                      context,
                      question.question,
                      question.isRequired,
                    ),
                    subtitle: GestureDetector(
                      onTap: () {
                        FocusScope.of(context)
                            .unfocus(); // Remove focus when tapping outside
                      },
                      child: SpeechEnabledTextField(
                          key: ValueKey('speech_${question.uuid}_single'),
                          autofocus: false,
                          keyboardType: question.keyboardPref,
                          enabled: question.isEditable,
                          onChanged: (value) =>
                              updateAnswer(question, value.trim()),
                          controller: textController,
                          decoration: InputDecoration(
                              hintText: question.question,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)))),
                    ),
                  ),
                  if (question.isIssue &&
                      question.answer?.trim().toLowerCase() ==
                          question.correctAnswer?.trim().toLowerCase())
                    issuesWidget(question, context, issuestextController)
                ],
              );
            case QuestionInputType.multiLineText:
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    title: _questionTitleWithRequired(
                      context,
                      question.question,
                      question.isRequired,
                    ),
                    subtitle: GestureDetector(
                      onTap: () {
                        FocusScope.of(context)
                            .unfocus(); // Remove focus when tapping outside
                      },
                      child: SpeechEnabledTextField(
                          key: ValueKey('speech_${question.uuid}_multi'),
                          autofocus: false,
                          onChanged: (value) => updateAnswer(question, value),
                          controller: textController,
                          enabled: question.isEditable,
                          minLines: 3,
                          maxLines: 3,
                          decoration: InputDecoration(
                              hintText: "Enter your answer..",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)))),
                    ),
                  ),
                  if (question.isIssue &&
                      question.answer?.trim().toLowerCase() ==
                          question.correctAnswer?.trim().toLowerCase())
                    issuesWidget(question, context, issuestextController)
                ],
              );

            case QuestionInputType.amount:
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: _questionTitleWithRequired(
                      context,
                      question.question,
                      question.isRequired,
                    ),
                    subtitle: GestureDetector(
                      onTap: () {
                        FocusScope.of(context)
                            .unfocus(); // Remove focus when tapping outside
                      },
                      child: TextField(
                        autofocus: false,
                        onChanged: (value) => updateAnswer(question, value),
                        controller: textController,
                        enabled: question.isEditable,
                        decoration: InputDecoration(
                            hintText: "Enter your answer..",
                            suffixIcon: const Icon(Icons.currency_rupee_sharp),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8))),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                  ),
                  if (question.isIssue &&
                      question.answer?.trim().toLowerCase() ==
                          question.correctAnswer?.trim().toLowerCase())
                    issuesWidget(question, context, issuestextController)
                ],
              );

            case QuestionInputType.number:
              final validation =
                  question.campQuestionModel?.inputTypeValidation;
              final maxLength = switch (validation) {
                'gst_number' => 15,
                'fssai_number' => 14,
                'udyam_number' => 19,
                _ => null,
              };
              final hintText = switch (validation) {
                'gst_number' => 'Enter 15-digit GST number',
                'fssai_number' => 'Enter 14-digit FSSAI number',
                'udyam_number' => 'Enter UDYAM number (UDYAM-XX-00-0000000)',
                _ => 'Enter your answer..',
              };
              final inputFormatters = switch (validation) {
                'udyam_number' => [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]'))
                  ],
                'gst_number' || 'pan_number' => [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Z]'))
                  ],
                'fssai_number' => [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                _ => question.keyboardPref == TextInputType.text
                    ? [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Z]'))
                      ]
                    : [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))
                      ],
              };
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: _questionTitleWithRequired(
                      context,
                      question.question,
                      question.isRequired,
                    ),
                    subtitle: GestureDetector(
                      onTap: () {
                        FocusScope.of(context)
                            .unfocus(); // Remove focus when tapping outside
                      },
                      child: TextField(
                        autofocus: false,
                        maxLength: maxLength,
                        inputFormatters: inputFormatters,
                        onChanged: (value) => updateAnswer(question, value),
                        enabled: question.isEditable,
                        controller: textController,
                        decoration: InputDecoration(
                            hintText: hintText,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8))),
                        keyboardType:
                            question.keyboardPref ?? TextInputType.number,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                  ),
                  if (question.isIssue &&
                      question.answer?.trim().toLowerCase() ==
                          question.correctAnswer?.trim().toLowerCase())
                    issuesWidget(question, context, issuestextController)
                ],
              );

            case QuestionInputType.multiSelectDropdown:
              return KeyedSubtree(
                key: ValueKey('dq_tile_${question.uuid}'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: _questionTitleWithRequired(
                        context,
                        question.question,
                        question.isRequired,
                      ),
                      subtitle: GestureDetector(
                        onTap: () {
                          question.isfromImage = true;
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 10),
                          child: AppPopup.dropDownMenuMutiselect(
                            key: ValueKey('dq_${question.uuid}'),
                            enabled: question.isEditable,
                            value: question.options
                                    .map((element) => element.trim())
                                    .contains(question.answer?.trim())
                                ? question.answer?.trim()
                                : null,
                            options: question.options,
                            placeholder:"Choose Options",
                            onBeforePopupopen: (p0) async {
                              question.isfromImage = true;
                              return null;
                            },
                            onChanged: (p0) {
                              context.hideKeyboard();
                              question.isfromImage = false;
                              updateAnswer(question, p0 ?? '');
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    if (question.isIssue &&
                        question.answer?.trim().toLowerCase() ==
                            question.correctAnswer?.trim().toLowerCase())
                      issuesWidget(question, context, issuestextController)
                  ],
                ),
              );

            case QuestionInputType.dropdown:
              return KeyedSubtree(
                key: ValueKey('dq_tile_${question.uuid}'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: _questionTitleWithRequired(
                        context,
                        question.question,
                        question.isRequired,
                      ),
                      subtitle: GestureDetector(
                        onTap: () {
                          question.isfromImage = true;
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 10),
                          child: AppPopup.dropDownMenu(
                            key: ValueKey('dq_${question.uuid}'),
                            enabled: question.isEditable,
                            value: question.options
                                    .map((element) => element.trim())
                                    .contains(question.answer?.trim())
                                ? question.answer?.trim()
                                : null,
                            options: question.options,
                            placeholder: "Choose your answer",
                            onBeforePopupopen: (p0) async {
                              question.isfromImage = true;
                              return null;
                            },
                            onChanged: (p0) {
                              context.hideKeyboard();
                              question.isfromImage = false;
                              updateAnswer(question, p0 ?? '');
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    if (question.isIssue &&
                        question.answer?.trim().toLowerCase() ==
                            question.correctAnswer?.trim().toLowerCase())
                      issuesWidget(question, context, issuestextController)
                  ],
                ),
              );
            case QuestionInputType.image:
              return inputImageTile(question, context, issuestextController);
            case QuestionInputType.radio:
              return inputRadioTile(question, context, issuestextController);
            case QuestionInputType.ddMMyy:
              return ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: _questionTitleWithRequired(
                    context,
                    question.question,
                    question.isRequired,
                  ),
                  subtitle: InkWell(
                    onTap: () async {
                      context.hideKeyboard();
                      final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1960),
                          lastDate: DateTime(DateTime.now().year + 1));
                      if (date != null) {
                        updateAnswer(
                            question,
                            date.toStringFormat(
                                question.dateTimeformat ?? "dd/MM/yyyy"));
                        setState(() {});
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                          hintText: question.placholder,
                          suffixIcon: const Icon(Icons.calendar_month_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: Text(question.answer ??
                          question.placholder ??
                          "dd/MM/yyyy"),
                    ),
                  ));
            case QuestionInputType.time:
              return ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: _questionTitleWithRequired(
                    context,
                    question.question,
                    question.isRequired,
                  ),
                  subtitle: InkWell(
                    onTap: () async {
                      context.hideKeyboard();
                      final time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        updateAnswer(
                            question,
                            time.toStringFormat(
                                question.dateTimeformat ?? "HH:mm"));
                        setState(() {});
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                          hintText: question.placholder,
                          suffixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: Text(
                          question.answer ?? question.placholder ?? "HH:mm"),
                    ),
                  ));

            case QuestionInputType.boolean:
              var q = question;
              q.options = ["Yes", "No"];
              return inputRadioTile(q, context, issuestextController);
            case QuestionInputType.multiAnswers:
              return checkBoxTile(question, context, issuestextController);
            case QuestionInputType.rating:
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: _questionTitleWithRequired(
                      context,
                      question.question,
                      question.isRequired,
                    ),
                    subtitle: GestureDetector(
                      onTap: () {
                        FocusScope.of(context)
                            .unfocus(); // Remove focus when tapping outside
                      },
                      child: RatingBar(
                          filledIcon: Icons.star,
                          emptyIcon: Icons.star_border,
                          onRatingChanged: (value) {
                            updateAnswer(question, value.toInt().toString());
                          },
                          initialRating: 0,
                          maxRating: 5),
                    ),
                  ),
                  if (question.isIssue &&
                      question.answer?.trim().toLowerCase() ==
                          question.correctAnswer?.trim().toLowerCase())
                    issuesWidget(question, context, issuestextController)
                ],
              );
          }
        },
      ),
    );
  }

  Widget inputRadioTile(QuestionModel question, BuildContext context,
      TextEditingController issuestextController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: _questionTitleWithRequired(
            context,
            question.question,
            question.isRequired,
          ),
          subtitle: GestureDetector(
            onTap: () {
              question.isfromImage = true;
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 10),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  return Row(
                    children: [
                      Radio(
                          value: option,
                          groupValue: question.answer,
                          onChanged: (val) {
                            context.hideKeyboard();
                            updateAnswer(question, val ?? '');
                            setState(() {});
                          }),
                      Expanded(child: Text(option))
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        if (question.isIssue &&
            question.answer?.trim().toLowerCase() ==
                question.correctAnswer?.trim().toLowerCase())
          issuesWidget(question, context, issuestextController)
      ],
    );
  }

  Widget checkBoxTile(QuestionModel question, BuildContext context,
      TextEditingController issuestextController) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: _questionTitleWithRequired(
            context,
            question.question,
            question.isRequired,
          ),
          subtitle: GestureDetector(
            onTap: () {
              question.isfromImage = true;
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 10),
              child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: question.options.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 10/ 1,
              mainAxisSpacing: 4,
              maxCrossAxisExtent: 1.sw / 2),
          itemBuilder: (context, index) {
            final option = question.options[index];
            return Row(
              children: [
                Checkbox(
                    value:
                        question.answer?.split(',').contains(option) ?? false,
                    onChanged: (newval) {
                      final val = newval == true;
                      context.hideKeyboard();
                      final ans = question.answer?.split(',') ?? [];
                      if (val) {
                        ans.add(option);
                      } else {
                        ans.remove(option);
                      }
                      ans.removeWhere((element) => element.isEmpty);
                      updateAnswer(question, ans.join(','));
                      setState(() {});
                    }),
                Flexible(child: Text(option,style: textTheme.bodyMedium,))
              ],
            );
          },
        )
            ),
          ),
        ),
        // _questionTitleWithRequired(
        //   context,
        //   question.question,
        //   question.isRequired,
        //   baseStyle: textTheme.bodyLarge,
        // ),
        // GridView.builder(
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   itemCount: question.options.length,
        //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        //       childAspectRatio: 3 / 1,
        //       mainAxisSpacing: 4,
        //       maxCrossAxisExtent: 1.sw / 2),
        //   itemBuilder: (context, index) {
        //     final option = question.options[index];
        //     return Row(
        //       children: [
        //         Checkbox(
        //             value:
        //                 question.answer?.split(',').contains(option) ?? false,
        //             onChanged: (newval) {
        //               final val = newval == true;
        //               context.hideKeyboard();
        //               final ans = question.answer?.split(',') ?? [];
        //               if (val) {
        //                 ans.add(option);
        //               } else {
        //                 ans.remove(option);
        //               }
        //               ans.removeWhere((element) => element.isEmpty);
        //               updateAnswer(question, ans.join(','));
        //               setState(() {});
        //             }),
        //         Flexible(child: Text(option))
        //       ],
        //     );
        //   },
        // ),
        if (question.isIssue &&
            (question.answer?.split(',') ?? [])
                .map((element) => element.trim())
                .contains(question.correctAnswer?.trim()))
          issuesWidget(question, context, issuestextController)
      ],
    );
  }

  Widget inputImageTile(QuestionModel question, BuildContext context,
      TextEditingController issuestextController) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: AlignmentGeometry.topLeft,
          child: _questionTitleWithRequired(
            context,
            question.question,
            question.isRequired,
            baseStyle: textTheme.titleMedium,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 80.h,
          width: 0.92.sw,
          decoration: BoxDecoration(
              border: Border.all(
                   
                  width: 0.5, 
                  strokeAlign: BorderSide.strokeAlignCenter)),
          child: InkWell(
            onTap: () async {
              try {
                FocusScope.of(context).unfocus();
                if (question.imageFrom == ImageFrom.gallery) {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                   // String imageUrl = await addTextToImage(image);
                    widget.onImageUpload
                        ?.call(question.uuid, image.path, false, -1);
                  }
                } else {
                  final image = await context.pushNamed<String>(
                      AppPaths.appcamera,
                      pathParameters: {'from': "question"});

                  if (image != null && image.isNotEmpty) {
                    widget.onImageUpload?.call(question.uuid, image, false, -1);
                  }
                }
              } catch (e) {
                context.showSnackBarMessage("optimization required.");
              }
            },
            child: question.answer == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.file_upload_outlined),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          question.placholder ?? "",
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                : (question.answer ?? "").isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.file_upload_outlined),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              question.placholder ?? "",
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      )
                    : (question.answer ?? "").trim().urlValid()
                        ? Image.network(question.answer!.trim())
                        : Image.file(
                            File(question.answer!),
                            fit: BoxFit.cover,
                          ),
          ),
        ),
        if (question.isIssue &&
            question.answer?.trim().toLowerCase() ==
                question.correctAnswer?.trim().toLowerCase())
          issuesWidget(question, context, issuestextController)
      ],
    );
  }

  Widget issuesWidget(QuestionModel question, BuildContext context,
      TextEditingController issuestextController) {
    final textTheme = Theme.of(context).textTheme;
    final issuesimage = question.issuesImage == null
        ? []
        : question.issuesImage?.split(",") ?? [];
    final length = widget.requiredMultiImageInCampaign
        ? issuesimage.length >= 4
            ? 4
            : issuesimage.length + 1
        : 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text.rich(
        TextSpan(
          style: textTheme.titleMedium,
          children: const [
            TextSpan(text: 'Upload issue Image'),
            TextSpan(
              text: '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        children: [
          for (int index = 0; index < length; index++)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              height: 80.h,
              width: length == 4
                  ? 0.21.sw
                  : length == 3
                      ? 0.30.sw
                      : length == 2
                          ? 0.45.sw
                          : 1.sw,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 0.5, strokeAlign: BorderSide.strokeAlignCenter)),
              child: InkWell(
                onTap: () async {
                  try {
                    FocusScope.of(context).unfocus();
                    final image = await context.pushNamed<String>(
                        AppPaths.appcamera,
                        pathParameters: {'from': "question"});

                    if (image != null && image.isNotEmpty) {
                      widget.onImageUpload
                          ?.call(question.uuid, image, true, index);
                    }
                  } catch (e) {
                    context.showSnackBarMessage("optimization required.");
                  }
                },
                child: issuesimage.isEmpty || index >= issuesimage.length
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.file_upload_outlined),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Upload Image",
                              // "issue image here..",
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      )
                    : (issuesimage[index]?.toString().isEmpty ?? false)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.file_upload_outlined),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Upload Image",
                                  style: textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          )
                        : (issuesimage[index]?.toString() ?? "").urlValid()
                            ? Image.network(
                                issuesimage[index]!.toString().trim())
                            : Image.file(
                                File(issuesimage[index]!.toString()),
                                fit: BoxFit.cover,
                              ),
              ),
            ),
        ],
      ),
      ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: Text.rich(
          TextSpan(
            style: textTheme.titleMedium,
            children: const [
              TextSpan(text: 'Issue Remark'),
              TextSpan(
                text: '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        subtitle: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus(); // Remove focus when tapping outside
          },
          child: SpeechEnabledTextField(
              key: ValueKey('speech_${question.uuid}_issue'),
              keyboardType: TextInputType.text,
              onChanged: (value) => updateIssuesRemark(question, value.trim()),
              controller: issuestextController,
              decoration: InputDecoration(
                  hintText: "Enter Issue Remark",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)))),
        ),
      ),
    ]);
  }

  void _syncControllerText(TextEditingController controller, String? value) {
    final next = value ?? '';
    if (controller.text != next) {
      controller.text = next;
    }
  }

  void updateAnswer(QuestionModel question, String newAnswer) {
    question.answer = newAnswer;
    if (question.questionType == QuestionInputType.singleLineText ||
        question.questionType == QuestionInputType.multiLineText ||
        question.questionType == QuestionInputType.amount ||
        question.questionType == QuestionInputType.number ||
        question.questionType == QuestionInputType.image) {
    } else {
      widget.onAnswerUpdate?.call(question.question, question.answer ?? "",question.questionOrder);
    }
  }

  void updateIssuesImage(QuestionModel question, String newAnswer) {
    question.issuesImage = newAnswer;
    widget.onAnswerUpdate?.call(question.question, question.answer ?? "",question.questionOrder);
  }

  void updateIssuesRemark(QuestionModel question, String newAnswer) {
    question.issuesRemark = newAnswer;
    // widget.onAnswerUpdate?.call(question.question, question.answer ?? "");
  }

  Future<String> getImageUrlPath(String imagePath) async {
    return await ImageCompressionHelper.instance.uploadCompressedImage(
      imagePath,
      widget.name,
      URLConstants.saveCampaignImage,
      widget.name,
    );
  }

  Future<XFile?> compressImage(String file, {int? reduceSize}) async {
    return await ImageCompressionHelper.instance.compressImageAsXFile(
      file,
      widget.name,
      quality: reduceSize,
    );
  }

  Future<String> addTextToImage(XFile imageFile) async {
    Position loc =
        await ContinuousLocationService.instance.resolveForSecureAction();
    String text =
        'DateTime: ${DateTime.now().toStringFormat("dd-MMM-yyyy hh:mm aa")}\nLatitude: ${loc.latitude}\nLongitude: ${loc.longitude}';

    // Convert the image to ui.Image
    final Uint8List bytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image image = frameInfo.image;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
    // Draw the original image
    canvas.drawImage(image, Offset.zero, Paint());

    // Add text
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.red,
          backgroundColor: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    );

    textPainter.layout();

    // Position at the bottom-right corner
    double x = image.width - textPainter.width - 20;
    double y = image.height - textPainter.height - 20;

    textPainter.paint(canvas, Offset(x, y));

    // Convert canvas to an image
    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    final ByteData? byteData =
        await img.toByteData(format: ui.ImageByteFormat.png);

    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final File file = File(imageFile.path);
    await file.writeAsBytes(pngBytes);
    return file.path;
  }
}
