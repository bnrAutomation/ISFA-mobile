import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/ui/app_image_picker.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/utility/extensions.dart';

import '../model.dart';

class DynamicQuestionsView extends StatefulWidget {
  final void Function()? onAnswerUpdate;
  final List<QuestionModel> questions;
  const DynamicQuestionsView(
      {super.key, required this.questions, this.onAnswerUpdate});

  @override
  State<DynamicQuestionsView> createState() => _DynamicQuestionsViewState();
}

class _DynamicQuestionsViewState extends State<DynamicQuestionsView> {
  List<TextEditingController> controllers = [];
  @override
  Widget build(BuildContext context) {
    if (controllers.length != widget.questions.length) {
      controllers = widget.questions
          .map((e) => TextEditingController(text: e.answer ?? ''))
          .toList();
    }
    return Theme(
      data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
              titleMedium: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: Colors.black))),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.questions.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final question = widget.questions[index];
          final textControler = controllers[index];
          switch (question.questionType) {
            case QuestionInputType.singleLineText:
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(question.question),
                    ),
                    if (question.isRequired)
                      const Text('*',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))
                  ],
                ),
                subtitle: TextField(
                    keyboardType: question.keyboardPref,
                    onChanged: (value) => updateAnswer(question, value.trim()),
                    controller: textControler,
                    decoration: InputDecoration(
                        hintText: question.question,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)))),
              );
            case QuestionInputType.multiLineText:
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(question.question),
                    ),
                    if (question.isRequired)
                      const Text('*',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))
                  ],
                ),
                subtitle: TextField(
                    onChanged: (value) => updateAnswer(question, value),
                    controller: textControler,
                    minLines: 3,
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText: "Enter your answer..",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)))),
              );

            case QuestionInputType.amount:
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(question.question),
                    ),
                    if (question.isRequired)
                      const Text('*',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))
                  ],
                ),
                subtitle: TextField(
                  onChanged: (value) => updateAnswer(question, value),
                  controller: textControler,
                  decoration: InputDecoration(
                      hintText: "Enter your answer..",
                      suffixIcon: const Icon(Icons.currency_rupee_sharp),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              );

            case QuestionInputType.number:
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(question.question),
                    ),
                    if (question.isRequired)
                      const Text('*',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))
                  ],
                ),
                subtitle: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) => updateAnswer(question, value),
                  controller: textControler,
                  decoration: InputDecoration(
                      hintText: "Enter your answer..",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                  keyboardType: TextInputType.number,
                ),
              );

            case QuestionInputType.dropdown:
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(question.question),
                    ),
                    if (question.isRequired)
                      const Text('*',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 10),
                  child: AppPopup.dropDownMenu(
                    value: question.answer,
                    options: question.options,
                    placeholder: "Choose your answer",
                    onChanged: (p0) {
                      context.hideKeyboard();
                      updateAnswer(question, p0 ?? '');
                      setState(() {});
                    },
                  ),
                ),
              );
            case QuestionInputType.image:
              return inputImageTile(question, context);
            case QuestionInputType.radio:
              return inputRadioTile(question, context);
            case QuestionInputType.ddMMyy:
              return ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(question.question),
                      ),
                      if (question.isRequired)
                        const Text('*',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                    ],
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
                        updateAnswer(question, date.toStringFormat("dd/MM/yy"));
                        setState(() {});
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                          hintText: question.placholder,
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: Text(
                          question.answer ?? question.placholder ?? "DD/MM/YY"),
                    ),
                  ));
            case QuestionInputType.boolean:
              var q = question;
              q.options = ["True", "False"];
              return inputRadioTile(q, context);
            case QuestionInputType.multiAnswers:
              return checkBoxTile(question, context);
          }
        },
      ),
    );
  }

  Widget inputRadioTile(QuestionModel question, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                question.question,
                style: textTheme.bodyLarge,
              ),
            ),
            if (question.isRequired)
              const Text('*',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))
          ],
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: question.options.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 3 / 1,
              mainAxisSpacing: 4,
              maxCrossAxisExtent: 1.sw / 2),
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
      ],
    );
  }

  Widget checkBoxTile(QuestionModel question, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                question.question,
                style: textTheme.bodyLarge,
              ),
            ),
            if (question.isRequired)
              const Text('*',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))
          ],
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: question.options.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 3 / 1,
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
                Flexible(child: Text(option))
              ],
            );
          },
        ),
      ],
    );
  }

  Widget inputImageTile(QuestionModel question, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                question.question,
                style: textTheme.titleMedium,
              ),
            ),
            if (question.isRequired)
              const Text('*',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 80.h,
          width: 1.sw,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 0.5, strokeAlign: BorderSide.strokeAlignCenter)),
          child: InkWell(
            onTap: () {
              AppImagePicker(context, (p0) {
                updateAnswer(question, p0.path);
                setState(() {});
              });
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
                : Image.file(
                    File(question.answer!),
                    fit: BoxFit.cover,
                  ),
          ),
        )
      ],
    );
  }

  void updateAnswer(QuestionModel question, String newAnswer) {
    question.answer = newAnswer;
    widget.onAnswerUpdate?.call();
  }
}
