
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/campaign_module/bloc/campaign_bloc.dart';
import 'package:i_densfa/module/campaign_module/view/campain_list.dart';
import 'package:i_densfa/module/campaign_module/widgets/offline_indicator.dart';
import 'package:i_densfa/module/my_schedule_module/bloc/my_schedule_bloc.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:upgrader/upgrader.dart';

class CampaignView extends StatelessWidget {
  final int storeId;
  final double storeLat;
  final double storeLong;
  final String from;
  final String mechanicsName;
  final String mechanicsContact;
  const CampaignView(
      {super.key,
      required this.storeId,
      required this.from,
      required this.storeLat,
      required this.storeLong,
      required this.mechanicsContact,
      required this.mechanicsName});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: Scaffold(
        body: BlocProvider(
          create: (context) => CampaignBloc(storeId, from, storeLat, storeLong)
            ..add(GetFilledCampaignsEvent(storeId.toString()))
            ..add(GetStoreCampaignsEvent(storeId.toString())),
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  final bloc = context.read<CampaignBloc>();
                  return OfflineIndicator(offlineService: bloc.repo.offlineService);
                },
              ),
              Expanded(
                child: BlocBuilder<CampaignBloc, CampaignState>(
            builder: (context, state) {
              final CampaignBloc bloc = context.read();

              // final companyName =
              //     AppStorage().userDetail?.companyName.toLowerCase();
              if (state is CampaignListLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }
              if (bloc.storeCampaigns.isEmpty) {
                return Center(
                    child: Text(
                  "No Campaign",
                  style: Theme.of(context).textTheme.labelLarge,
                ));
              }

              if (state is CampaignQuestionsLoadedForState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (bloc.selectedCampSections.isEmpty) {
                    bloc.add(SnackbarMessageCampaignEvent(
                        message: 'No Questions added.'));
                  } else {
                    for (var element in bloc.questionAnswers) {
                      element.answer = null;
                    }
                    bloc.selectedMechanicContact = mechanicsContact;
                    bloc.selectedMechanicName = mechanicsName;
                    context
                        .pushNamed(AppPaths.campaignQuestion, extra: bloc)
                        .then((value) {
                      if (value == true) {
                        // Refresh schedule data if MyScheduleBloc is available
                        try {
                          final scheduleBloc = context.read<MyScheduleBloc>();
                          scheduleBloc.add(MyScheduleUpdateData());
                        } catch (e) {
                          // MyScheduleBloc not available in this context, that's okay
                        }
                        Navigator.pop(context);
                      }
                      bloc.add(GetFilledCampaignsEvent(storeId.toString()));
                      bloc.add(GetStoreCampaignsEvent(storeId.toString()));
                    });
                  }
                });
              }

              return AnimationLimiter(
                child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bloc.storeCampaigns.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 5),
                    itemBuilder: (context, index) => state
                                is CampaignQuestionsLoadedState &&
                            bloc.indexCampaign == index
                        ? Card(
                            elevation: 0,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: SizedBox(
                                    width: 1.sw,
                                    height: 50.sp,
                                    child: const Center(
                                        child: Text(
                                            "Please Wait..\nLoading...")))))
                        : InkWell(
                            onTap: () {
                              if ((AppStorage()
                                          .userDetail
                                          ?.configuration
                                          .requiresAllFillCampigned ??
                                      false) &&
                                  bloc.filledCampaignList.contains(
                                      bloc.storeCampaigns[index].uuid) || bloc.alreadyVisited) {
                                context
                                    .showSnackBarMessage("You already filled.");
                                return;
                              }
                               bloc.selectedMechanicContact = mechanicsContact;
                              bloc.selectedMechanicName = mechanicsName;
                              bloc.selectedCampaign = bloc.storeCampaigns[index];
                              bloc.add(GetCampaignSectionsFirstTime(bloc.storeCampaigns[index].uuid, index));

                              // context.push(AppPaths.selectedCampaignView, extra: bloc).then((value) => {
                              //           bloc.add(GetFilledCampaignsEvent(
                              //               storeId.toString())),
                              //           bloc.add(GetStoreCampaignsEvent(
                              //               storeId.toString())),
                              //         });
                            },
                            child: AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 500),
                              child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: CampaignListItem(
                                      item: bloc.storeCampaigns[index],
                                      isfilled: bloc.filledCampaignList
                                          .contains(bloc
                                              .storeCampaigns[index].uuid) || bloc.alreadyVisited)),
                            ))),
              );
            },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CampaignSearchBar extends StatelessWidget {
  const CampaignSearchBar({super.key});
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
            hintText: "Search by campaign name.",
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

class SelectedCampaignView extends StatelessWidget {
  const SelectedCampaignView({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xffBFD1DF),
      appBar: AppBar(title: const Text("Campaign")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: BlocConsumer<CampaignBloc, CampaignState>(
          listener: (context, state) {
            // Snackbar messages are handled in CampaignQuestionsView to avoid duplicates
          },
          builder: (context, state) {
            final CampaignBloc bloc = context.read();
            final selectedCamp = bloc.selectedCampaign;
           // final campaignData = bloc.savedCampaignDetails;
            return Column(
              children: [
                //_userCard(),
                if (selectedCamp != null)
                  Card(
                    child: ListTile(
                      textColor: theme.primaryColor,
                      horizontalTitleGap: 5,
                      leading: Icon(
                        Icons.calendar_month_outlined,
                        color: theme.primaryColor,
                      ),
                      title: Text(selectedCamp.name),
                      subtitle: Text(
                          "From ${selectedCamp.startDate.toStringFormat('dd MMM yy')} To ${selectedCamp.endDate.toStringFormat('dd MMM yy')}"),
                    ),
                  ),
                if (!bloc.storeId.isNegative &&
                    selectedCamp != null &&
                    selectedCamp.isNegative() == false)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: FilledButton(
                        onPressed: () {
                          if (bloc.selectedCampSections.isEmpty) {
                            bloc.add(SnackbarMessageCampaignEvent(
                                message: 'No Questions added.'));
                            return;
                          }
                          for (var element in bloc.questionAnswers) {
                            element.answer = null;
                          }
                          //  bloc.selectedMechanicContact = mechanicsContact;
                          // bloc.selectedMechanicName = mechanicsName;
                          context
                              .pushNamed(AppPaths.campaignQuestion, extra: bloc)
                              .then((value) {
                                if (value == true) {
                                  // Refresh schedule data if MyScheduleBloc is available
                                  try {
                                    final scheduleBloc = context.read<MyScheduleBloc>();
                                    scheduleBloc.add(MyScheduleUpdateData());
                                  } catch (e) {
                                    // MyScheduleBloc not available in this context, that's okay
                                  }
                                  Navigator.pop(context);
                                }
                              });
                        },
                        style: TextButton.styleFrom(
                          elevation: 2,
                          alignment: Alignment.center,
                          backgroundColor: theme.primaryColor,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text('Enter Questionnaire',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp, color: Colors.white)),
                        )),
                  ),
                // campaignData != null
                //     ? Card(
                //         child: Padding(
                //           padding: EdgeInsets.all(12.w),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Row(
                //                 children: [
                //                   Text(
                //                     campaignData.targetedStores.toString(),
                //                     style: TextStyle(
                //                         color: theme.primaryColor,
                //                         fontWeight: FontWeight.bold,
                //                         fontSize: 20.sp),
                //                   ),
                //                   SizedBox(width: 10.w),
                //                   const Text("Store Targeted"),
                //                 ],
                //               ),
                //               SizedBox(height: 15.h),
                //               Row(
                //                 children: [
                //                   Text(
                //                     campaignData.totalResponse.toString(),
                //                     style: TextStyle(
                //                         color: theme.primaryColor,
                //                         fontWeight: FontWeight.bold,
                //                         fontSize: 20.sp),
                //                   ),
                //                   SizedBox(width: 10.w),
                //                   const Text("Total Responses"),
                //                 ],
                //               ),
                //               SizedBox(height: 15.h),
                //               Row(
                //                 children: [
                //                   Text(
                //                     campaignData.includedStores.toString(),
                //                     style: TextStyle(
                //                         color: theme.primaryColor,
                //                         fontWeight: FontWeight.bold,
                //                         fontSize: 20.sp),
                //                   ),
                //                   SizedBox(width: 10.w),
                //                   const Text("Store Included in Responses"),
                //                 ],
                //               ),
                //               SizedBox(height: 6.h),
                //               ClipRRect(
                //                 borderRadius: BorderRadius.circular(20.w),
                //                 child: LinearProgressIndicator(
                //                   backgroundColor: Colors.grey.shade400,
                //                   color: const Color(0xffDB4C5B),
                //                   minHeight: 40,
                //                   value: max(0.0, campaignData.totalResponse) /
                //                       max(1, campaignData.targetedStores),
                //                 ),
                //               ),
                //               SizedBox(height: 6.h),
                //             ],
                //           ),
                //         ),
                //       )
                //     : const Center(child: Text("Analytics is not available.")),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget _userCard() {
  //   final user = AppStorage().userDetail;
  //   if (user == null) {
  //     return const SizedBox();
  //   }
  //   return Card(
  //     child: ListTile(
  //       leading: CircleAvatar(
  //         radius: 25.w,
  //         backgroundColor: Colors.grey.withValues(alpha:0.2),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(110),
  //           child: CachedNetworkImage(
  //             imageUrl: user.photoUrl,
  //             fit: BoxFit.cover,
  //             errorWidget: (context, url, error) => CachedNetworkImage(
  //                 imageUrl: ImageConstants.placeholderUserUrl),
  //           ),
  //         ),
  //       ),
  //       title: Text(user.username),
  //       subtitle: Text(user.reportTo),
  //     ),
  //   );
  // }
}
