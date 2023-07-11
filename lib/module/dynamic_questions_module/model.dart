import 'package:flutter/material.dart';
import 'package:i_densfa/module/assessment_module/assessment_model.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';

class QuestionModel {
  final String question;
  String? answer;
  final QuestionInputType questionType;
  final String? placholder;
  List<String> options;
  final TextInputType? keyboardPref;
  final bool isRequired;
  AssessQuestionModel? assessmentQuestionDetails;
  CampaignQuestionModel? campQuestionModel;

  QuestionModel(
      {required this.question,
      required this.questionType,
      this.placholder,
      this.keyboardPref,
      this.answer,
      required this.options,
      required this.isRequired,
      this.assessmentQuestionDetails,
      this.campQuestionModel});

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

  Map<String, dynamic> toCampaignRequest() {
    return {
      "options": options,
      "questionText": question,
      "questionType": questionType.toStringName(),
      "userAnswer": answer ?? "",
      "campaignId": campQuestionModel?.uuid,
      "id": campQuestionModel?.uuid,
    };
  }
}
