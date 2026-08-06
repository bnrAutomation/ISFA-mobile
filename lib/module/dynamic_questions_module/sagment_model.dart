import 'package:i_densfa/module/dynamic_questions_module/model.dart';

class SegmentModel {
  String name;
  List<QuestionModel> questionAnswers = [];
  SegmentModel(this.questionAnswers,this.name);
}
