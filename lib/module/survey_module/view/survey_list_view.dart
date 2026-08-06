import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/survey_module/bloc/survey_bloc.dart';
import 'package:i_densfa/module/survey_module/models/survey_model.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:upgrader/upgrader.dart';

class SurveyListView extends StatelessWidget {
  final String name;
  const SurveyListView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: Scaffold(
        appBar: AppBar(title: Text(name)),
        body: BlocProvider(
          create: (context) => SurveyBloc()..add(GetSurveysEvent()),
          child: BlocBuilder<SurveyBloc, SurveyState>(
            builder: (context, state) {
              final SurveyBloc bloc = context.read();
              if (state is SurveyListLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }
              if (bloc.surveyList.isEmpty) {
                return Center(
                    child: Text(
                  "No Survey",
                  style: Theme.of(context).textTheme.labelLarge,
                ));
              }
              return AnimationLimiter(
                child: ListView.separated(
                    itemCount: bloc.surveyList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 5),
                    itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          final survey = bloc.surveyList[index];
                          bloc.selectedSurvey = survey;
                          bloc.add(GetClientEvent());
                          bloc.add(GetNotesEvent());
                          bloc.add(GetSurveyVisitEvent());
                          bloc.add(
                              GetFilledSurveysEvent(surveyUuid: survey.uuid));
                          context.push(AppPaths.selectedSurveyDetail,
                              extra: bloc);
                        },
                        child: AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                              verticalOffset: 50.0,
                              child:
                                  SurveyListItem(item: bloc.surveyList[index])),
                        ))),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SurveySearchBar extends StatelessWidget {
  const SurveySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Theme.of(context).primaryColor,
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: Colors.white,
              size: 16,
            ),
            hintText: "Search by Survey name.",
            hintStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
            iconColor: Colors.white,
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.white),
                borderRadius: BorderRadius.circular(40)),
            enabledBorder: OutlineInputBorder(
                gapPadding: 30,
                borderSide: const BorderSide(width: 1, color: Colors.white),
                borderRadius: BorderRadius.circular(40)),
            border: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Colors.white),
                borderRadius: BorderRadius.circular(40))),
      ),
    );
  }
}

class SurveyListItem extends StatelessWidget {
  final SurveyListItemModel item;
  const SurveyListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 1.sw, height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                  ),
                  Text(
                    "Active",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                  const SizedBox(width: 10)
                ],
              ),
              Text(
                "Description : ${item.description}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "From : ",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    item.startDate.toStringFormat("d MMM yyyy"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "To : ",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    item.endDate.toStringFormat("d MMM yyyy"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              SizedBox(width: 1.sw, height: 5),
            ],
          )),
    );
  }
}
