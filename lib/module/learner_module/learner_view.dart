import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/learner_module/learner/learner_bloc.dart';
import 'package:i_densfa/module/learner_module/learner_repository.dart';
import 'package:i_densfa/routes.dart';
import 'package:upgrader/upgrader.dart';

class LearnerView extends StatelessWidget {
  const LearnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: Scaffold(
        // backgroundColor: Theme.of(context).colorScheme.onSurface,
        body: RepositoryProvider(
          create: (context) => LearnerRepository(),
          child: BlocProvider(
            create: (context) => LearnerBloc(context.read())..add(GetLearner()),
            child: BlocConsumer<LearnerBloc, LearnerState>(
              listener: (context, state) {},
              builder: (context, state) {
                var bloc = context.read<LearnerBloc>();
                return (state is LearnerLoadingState)
                    ? const Center(child: CircularProgressIndicator())
                    : bloc.dataList.isEmpty
                        ? const Center(child: Text("No data"))
                        : ListView.separated(
                            padding: const EdgeInsets.all(10),
                            itemCount: bloc.dataList.length,
                            separatorBuilder: (context, index) => Container(
                              color: Colors.grey.shade400,
                              width: 1.sw,
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  width: 1.sw,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                          color: Theme.of(context).cardColor,
                                        )
                                      ]),
                                  child: ExpansionTile(
                                    backgroundColor: Colors.transparent,
                                    shape:
                                        Border.all(color: Colors.transparent),
                                    title: Text(bloc.dataList[index].title),
                                    children: [
                                      InkWell(
                                        onTap: () => context.pushNamed(
                                            AppPaths.appwebview,
                                            pathParameters: {
                                              'link': bloc.dataList[index].link,
                                              "contentType":bloc.dataList[index].contentType
                                            }),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 20),
                                          height: 80.h,
                                          width: 1.sw,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(width: 0.5),
                                            borderRadius:
                                                BorderRadius.circular(2.5),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              bloc.dataList[index].clientId
                                                          .toLowerCase() ==
                                                      "Apple".toLowerCase()
                                                  ? const Icon(
                                                      Icons.image_outlined,
                                                      color: Colors.blue)
                                                  : Icon(
                                                      bloc.dataList[index]
                                                                  .contentType ==
                                                              "image"
                                                          ? Icons.image_outlined
                                                          : bloc.dataList[index]
                                                                      .contentType ==
                                                                  "video"
                                                              ? Icons.video_file
                                                              : Icons
                                                                  .document_scanner,
                                                      color: Colors.blue),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Click for start learning..",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ));
                            },
                          );
              },
            ),
          ),
        ),
      ),
    );
  }
}
