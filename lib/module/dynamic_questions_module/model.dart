import 'package:flutter/material.dart';
import 'package:i_densfa/module/assessment_module/assessment_model.dart';

class QuestionModel {
  final String question;
  String? answer;
  final QuestionInputType questionType;
  final String? placholder;
  List<String> options;
  final TextInputType? keyboardPref;
  final bool isRequired;
  AssessQuestionModel? assessmentQuestionDetails;

  QuestionModel(
      {required this.question,
      required this.questionType,
      this.placholder,
      this.keyboardPref,
      required this.options,
      required this.isRequired,
      this.assessmentQuestionDetails})
      : assert(
            (questionType == QuestionInputType.dropdown ||
                    questionType == QuestionInputType.radio)
                ? options.isNotEmpty
                : options.isEmpty,
            'Dropdown/radio question must have options to show');

  Map<String, dynamic> toAssessmentRequest() {
    return {
      "options": options,
      "questionText": question,
      "questionType": questionType.toStringName(),
      "userAnswer": answer ?? "",
      "assessmentId": assessmentQuestionDetails?.assessmentId,
      "correctAnswer": assessmentQuestionDetails?.correctAnswer,
      "id": assessmentQuestionDetails?.id,
      "sequence": assessmentQuestionDetails?.sequence,
    };
  }
}
