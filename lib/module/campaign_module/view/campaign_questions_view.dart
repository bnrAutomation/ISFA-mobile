import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/campaign_module/bloc/campaign_bloc.dart';
import 'package:i_densfa/module/dynamic_questions_module/views/dynamic_questions_view.dart';

class CampaignQuestionsView extends StatelessWidget {
  const CampaignQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final CampaignBloc bloc = context.read();

    return WillPopScope(
      onWillPop: () async {
        final response = await _showQuitWarning(context, bloc);
        if (response == "Yes") {
          bloc.add(SaveCampaignAnswersEvent(false));
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Campaign",
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocConsumer<CampaignBloc, CampaignState>(
                listenWhen: (previous, current) =>
                    current is ScoreCalculatedCampaignState,
                listener: (context, state) {
                  if (state is ScoreCalculatedCampaignState) {
                    Navigator.pop(context);
                  }
                },
                buildWhen: (previous, current) =>
                    current is CampaignQuestionsLoadedState,
                builder: (context, state) {
                  return DynamicQuestionsView(questions: bloc.questionAnswers);
                },
              ),
              Align(
                  child: FilledButton(
                      style: TextButton.styleFrom(
                        elevation: 2,
                        alignment: Alignment.center,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: bloc.state is SavingAnswersLoadingState
                          ? null
                          : () => bloc.add(SaveCampaignAnswersEvent(true)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "SUBMIT",
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      )))
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showQuitWarning(BuildContext context, CampaignBloc bloc) {
    return showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text("Are you sure you want to quit Campaign"),
            cancelButton: TextButton(
                onPressed: () => Navigator.pop(context, 'No'),
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.red),
                )),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, 'Yes'),
                  child: const Text('Yes')),
            ],
          );
        });
  }
}
