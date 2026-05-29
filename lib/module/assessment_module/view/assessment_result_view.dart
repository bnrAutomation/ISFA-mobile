import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/assessment_module/assessment/assessment_bloc.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:multi_circular_slider/multi_circular_slider.dart';

class AssessmentResult extends StatelessWidget {
  const AssessmentResult({super.key});

  @override
  Widget build(BuildContext context) {
    final AssessmentBloc bloc = context.read();
    return Scaffold(
        appBar: AppBar(title: const Text("Score Card")),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              height: 20,
              width: 1.sw,
            ),
            Text(
              "Your Score",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(
              height: 20,
            ),
            MultiCircularSlider(
              size: 0.7.sw,
              progressBarType: MultiCircularSliderType
                  .circular, // the type of indictor you want circular or linear
              values: [
                (bloc.assessmentResponse!.rightAnswers /
                    bloc.assessmentResponse!.totalQuestions),
                (bloc.assessmentResponse!.unattemptedQuestions /
                    bloc.assessmentResponse!.totalQuestions),
                (bloc.assessmentResponse!.wrongAnswers /
                    bloc.assessmentResponse!.totalQuestions)
              ],
              colors: const [
                Color(0xFF18C737),
                Color(0xFFFFCC05),
                Color(0xFFFD1960)
              ],
              showTotalPercentage: true,
              percentageTextStyle: TextStyle(fontSize: 18.sp),
              label:
                  '${bloc.assessmentResponse?.marksScored ?? 0}/${bloc.assessmentResponse?.maximumMarks ?? 0}',
              animationDuration: const Duration(milliseconds: 500),
              animationCurve: Curves.easeIn,
              innerIcon: const Icon(Icons.school_rounded),
              trackColor: Colors.grey,
              labelTextStyle: const TextStyle(color: Colors.amber),
              //percentageTextStyle: const TextStyle(),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF18C737),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 3),
                          ),
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Achieved",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.black),
                    )
                  ],
                )),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFCC05),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 3),
                          ),
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "In Process",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.black),
                    )
                  ],
                )),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFD1960),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 3),
                          ),
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Failed",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.black),
                    )
                  ],
                ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  bloc.assessmentResponse?.isQualifiedForCurrentLevel ?? false
                      ? Text(
                          "🎉🎉Congratulation!!🎉🎉 \n🎉🎉You have qualified current level.🎉🎉",
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.green,
                                  ),
                        )
                      : Text(
                          "😔 You haven't Qualified Current Level.😔",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                      buttonText:
                          bloc.assessmentResponse?.isQualifiedForCurrentLevel ??
                                  false
                              ? "Continue To Next"
                              : "Move To Assessment",
                      onPressed: () => {
                            if (bloc.assessmentResponse
                                    ?.isQualifiedForCurrentLevel ??
                                false)
                              {
                                bloc.add(GetAssessmentLevel(
                                    bloc.selectedAssessment!)),
                                Navigator.pop(context)
                              }
                            else
                              {
                                bloc.add(GetAssessmentEvent()),
                                Navigator.pop(context),
                                Navigator.pop(context),
                              }
                          },
                      isLoading: false,
                      isSuccess: false)
                ],
              ),
            )
          ]),
        ));
  }
}
