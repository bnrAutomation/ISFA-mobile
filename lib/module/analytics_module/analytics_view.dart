import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:i_densfa/module/analytics_module/analytics/analytics_bloc.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'analytics_repository.dart';

class AnalyticsView extends StatelessWidget {
  final int? forUserId;
  const AnalyticsView({super.key, this.forUserId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RepositoryProvider(
      create: (context) => AnalyticsRepository(forUserId),
      lazy: false,
      child: BlocProvider(
        lazy: false,
        create: (context) =>
            AnalyticsBloc(context.read())..add(GetAnalyticsEvent()),
        child: Scaffold(
          appBar:
              forUserId != null ? AppBar(title: const Text('Analytics')) : null,
          body: Builder(builder: (context) {
            final AnalyticsBloc bloc = context.read();
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xff959595), Color(0xff636363)])),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Align(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              borderedBox(
                                child: CachedNetworkImage(
                                  imageUrl: bloc.userDetails.photoUrl,
                                  width: 80,
                                  height: 80,
                                  errorWidget: (context, url, error) =>
                                      CachedNetworkImage(
                                          imageUrl: ImageConstants
                                              .placeholderUserUrl),
                                ),
                              ),
                              Text(bloc.userDetails.fullName,
                                  style: textTheme.bodyLarge
                                      ?.copyWith(color: Colors.white)),
                              Text(bloc.userDetails.designation,
                                  style: textTheme.bodySmall
                                      ?.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () => bloc.add(GetAnalyticsEvent()),
                            color: Colors.white,
                            iconSize: 30,
                            icon:
                                const Icon(Icons.replay_circle_filled_rounded),
                          ),
                        )
                      ],
                    ),
                  ),
                  BlocBuilder<AnalyticsBloc, AnalyticsState>(
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButton<int>(
                          isExpanded: true,
                          itemHeight: 70,
                          padding: EdgeInsets.zero,
                          underline: const SizedBox(),
                          icon: const SizedBox(),
                          value: bloc.selectedDays,
                          items: bloc.daysFilterOptions.map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          selectedItemBuilder: (context) =>
                              bloc.daysFilterOptions
                                  .map((e) => Container(
                                        padding: const EdgeInsets.all(12),
                                        height: 70,
                                        child: IgnorePointer(
                                          child: CustomMaterialButton(
                                            buttonText:
                                                "Analytics for last $e days",
                                            onPressed: () {},
                                          ),
                                        ),
                                      ))
                                  .toList(),
                          onChanged: (days) {
                            if (days != null) {
                              bloc.add(AnalyticsDaysChangeEvent(days));
                            }
                          },
                        ),
                      );
                    },
                  ),
                  _analyticsList()
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  BlocBuilder<AnalyticsBloc, AnalyticsState> _analyticsList() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        final AnalyticsBloc bloc = context.read();
        return state is LoadingState
            ? SizedBox(
                width: 1.sw,
                height: 0.5.sh,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : AnimationLimiter(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bloc.analyticsList.length,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final TextTheme textTheme = Theme.of(context).textTheme;
                    final item = bloc.analyticsList[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                border: Border.all(color: ColorConstants.amber),
                                boxShadow: const [
                                  BoxShadow(
                                    color: ColorConstants.amber,
                                    blurRadius: 1,
                                    spreadRadius: 0.5,
                                  )
                                ]),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.kpiName,
                                          style: textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10.sp),
                                        ),
                                        Text(
                                          "Target",
                                          style: textTheme.titleSmall,
                                        ),
                                        Text(
                                          item.target.toString(),
                                          style: textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Text(
                                        "Achieved",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      Text(
                                        item.achieved.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  // width: 75,
                                  // height: 60,
                                  child: CircularPercentIndicator(
                                    radius: 40.0,
                                    lineWidth: 13,
                                    percent: item.percentage / 100,
                                    backgroundColor: const Color(0xffededee),
                                    center: Text(
                                        "${item.percentage.toStringAsFixed(1)}%"),
                                    progressColor: Colors.amber,
                                    animation: true,
                                    animationDuration: 2000,
                                    restartAnimation: false,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
      },
    );
  }

  Widget borderedBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.amber),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
    );
  }

  Widget shadowBox({required Widget child}) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  color: ColorConstants.amber, blurRadius: 2, spreadRadius: 2)
            ]),
        child: child);
  }
}
