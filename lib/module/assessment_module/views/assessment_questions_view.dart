import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../dynamic_questions_module/model.dart';
import '../../dynamic_questions_module/views/dynamic_questions_view.dart';

class AssessmentQuestionsView extends StatelessWidget {
  const AssessmentQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Assessment",
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sales Log Form",
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  DynamicQuestionsView(questions: dummySalesLogFormList),
                ],
              ),
            ),
            Container(
              color: const Color(0xff278bbc).withOpacity(0.2),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer Details",
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  DynamicQuestionsView(questions: dummyCustomerDetails),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: DynamicQuestionsView(questions: dummyOtherInfo),
            ),
            Align(
                child: FilledButton(
                    style: TextButton.styleFrom(
                      elevation: 2,
                      alignment: Alignment.center,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "SUBMIT",
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    )))
          ],
        ),
      ),
    );
  }
}
