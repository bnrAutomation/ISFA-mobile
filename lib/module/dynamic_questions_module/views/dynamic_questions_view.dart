import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/assessment_module/assessment_model.dart';
import 'package:i_densfa/module/ui/app_image_picker.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/utility/extensions.dart';

import '../model.dart';

class DynamicQuestionsView extends StatefulWidget {
  const DynamicQuestionsView({super.key, required this.questions});

  final List<QuestionModel> questions;

  @override
  State<DynamicQuestionsView> createState() => _DynamicQuestionsViewState();
}

class _DynamicQuestionsViewState extends State<DynamicQuestionsView> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
              titleMedium: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: Colors.black))),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final question = widget.questions[index];
          switch (question.questionType) {
            case QuestionInputType.singleLineText:
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Text(question.question),
                subtitle: TextField(
                    onChanged: (value) {
                      question.answer = value.trim().capitalizeFirst();
                    },
                    decoration: InputDecoration(
                        hintText: "Enter your answer..",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)))),
              );
            case QuestionInputType.multiLineText:
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                title: Text(question.question),
                subtitle: TextField(
                    onChanged: (value) {
                      question.answer = value;
                    },
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
                title: Text(question.question),
                subtitle: TextField(
                  onChanged: (value) {
                    question.answer = value;
                  },
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
                title: Text(question.question),
                subtitle: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    question.answer = value;
                  },
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
                title: Text(question.question),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 10),
                  child: AppPopup.dropDownMenu(
                    value: question.answer,
                    options: question.options,
                    placeholder: "Choose your answer",
                    onChanged: (p0) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      question.answer = p0;
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
                  title: Text(question.question),
                  subtitle: InkWell(
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final DateTime date = await showDialog(
                          context: context,
                          builder: (c) {
                            return DatePickerDialog(
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1960),
                                lastDate: DateTime(DateTime.now().year + 1));
                          });
                      question.answer = date.toStringFormat("dd/MM/yy");
                      setState(() {});
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
        Text(
          question.question,
          style: textTheme.titleMedium,
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: question.options.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 4 / 1,
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
                      FocusScope.of(context).requestFocus(FocusNode());
                      question.answer = val;
                      setState(() {});
                    }),
                Text(option)
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
        Text(
          question.question,
          style: textTheme.titleMedium,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 80.h,
          width: 1.sw,
          decoration: BoxDecoration(
              border: Border.all(strokeAlign: BorderSide.strokeAlignCenter)),
          child: InkWell(
            onTap: () {
              AppImagePicker(context, (p0) {
                question.answer = p0.path;
                setState(() {});
              });
            },
            child: question.answer == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.file_upload_outlined),
                      const SizedBox(height: 8),
                      Text(
                        question.placholder ?? "",
                        style: textTheme.bodyMedium,
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
}
