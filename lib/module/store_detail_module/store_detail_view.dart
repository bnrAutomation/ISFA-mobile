import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/module/promoter_module/feedback/feedback_view.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:i_densfa/module/campaign_module/view/campaign_view.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';

import '../../utility/app_constants.dart';
import 'bloc/store_detail_bloc.dart';

class StoreDetailView extends StatelessWidget {
  const StoreDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingButtons(),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: BlocConsumer<StoreDetailBloc, StoreDetailState>(
          listenWhen: (previous, current) =>
              current is StoreDetailToastMessageState ||
              current is CompaignsLoadedStoreDetailState,
          listener: (context, state) {
            if (state is StoreDetailToastMessageState) {
              context.showSnackBarMessage(state.message);
            } else if (state is CompaignsLoadedStoreDetailState) {
              final StoreDetailBloc bloc = context.read();
              AppPopup.showAppBottomSheet(
                  context: context,
                  child: _openCampaignSheet(context, bloc.beatPlanModel));
            }
          },
          builder: (context, state) {
            return state is MarkingLoadingStoreDetailState
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      headerImage(context),

                      nameAddress(context),
                      // blueCard(context,
                      //     leadingSVGImage: ImageConstants.miniCalendar,
                      //     subtitle: 'Scheduled visits & Calls',
                      //     title: '28 Feb 2023',
                      //     trailingSVGImage: ImageConstants.visitsCalls),
                      InkWell(
                        onTap: () {
                          AppPopup.showAppBottomSheet(
                              context: context,
                              child: BlocProvider.value(
                                value: context.read<StoreDetailBloc>()
                                  ..add(GetFeedbackEvent()),
                                child: feebackListView(context),
                              ));
                        },
                        child: blueCard(context,
                            leadingSVGImage: ImageConstants.feedback,
                            title: 'Feedback',
                            subtitle:
                                'Feedback that you had given before to this store.',
                            trailingSVGImage: ImageConstants.feedback),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: recentNote(context),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: StoreDetailCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(ImageConstants.statistic),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Stage",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                      Text("Select Stage",
                                          style: GoogleFonts.inter(
                                              fontSize: 10.sp,
                                              color: const Color(0xff278BBC))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: StoreDetailCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(ImageConstants.stars),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Class",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                      Text(
                                        "Select Class",
                                        style: GoogleFonts.inter(
                                            fontSize: 10.sp,
                                            color: const Color(0xff278BBC)),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // StoreDetailCard(
                      //   child: ListTile(
                      //     title: Text("Sub Dealer History",
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .titleMedium
                      //             ?.copyWith(color: Theme.of(context).primaryColor)),
                      //     subtitle: Row(
                      //       children: [
                      //         Text("Last Activity:",
                      //             style: Theme.of(context).textTheme.titleSmall),
                      //         Text("Compaign, 28 Feb 2023",
                      //             style: Theme.of(context)
                      //                 .textTheme
                      //                 .titleSmall
                      //                 ?.copyWith(color: Colors.grey)),
                      //       ],
                      //     ),
                      //     trailing: Icon(Icons.arrow_forward_ios,
                      //         color: Theme.of(context).primaryColor),
                      //   ),
                      // ),
                      // StoreDetailCard(
                      //   child: ListTile(
                      //     title: Text("More",
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .titleMedium
                      //             ?.copyWith(color: Theme.of(context).primaryColor)),
                      //     trailing: Icon(Icons.arrow_forward_ios,
                      //         color: Theme.of(context).primaryColor),
                      //   ),
                      // ),
                      const SizedBox(height: 100)
                    ],
                  );
          },
        ),
      ),
    );
  }

  Builder _floatingButtons() {
    return Builder(
      builder: (context) {
        final bloc = context.read<StoreDetailBloc>();
        if (!bloc.beatPlanModel.markin) {
          return const SizedBox();
        } else {
          return SpeedDial(
              speedDialChildren: [
                SpeedDialChild(
                  child: const Icon(Icons.campaign),
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  label: 'Campaign',
                  onPressed: () => bloc.add(GotoCompaignEvent()),
                  closeSpeedDialOnPressed: false,
                ),
                SpeedDialChild(
                  child: const Icon(Icons.feedback),
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  label: 'Feedback',
                  onPressed: () {
                    final storeDetail = bloc.details;
                    if (storeDetail != null) {
                      AppPopup.showAppBottomSheet(
                        context: context,
                        child: FeedbackView(storeName: storeDetail.name),
                      );
                    }
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.schedule),
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  label: 'Schedule',
                  onPressed: () {
                    context.pushNamed(AppPaths.scheduleVisit,
                        extra: [bloc.beatPlanModel]);
                  },
                ),
              ],
              closedForegroundColor: Colors.white,
              closedBackgroundColor: Theme.of(context).primaryColor,
              openForegroundColor: Theme.of(context).primaryColor,
              openBackgroundColor: Colors.white,
              child: Icon(
                Icons.add,
                size: 30.w,
              ));
        }
      },
    );
  }

  Widget recentNote(BuildContext context) {
    final StoreDetailBloc bloc = context.read();
    return InkWell(
      onTap: () {
        AppPopup.showAppBottomSheet(
            context: context,
            child: BlocProvider.value(
              value: bloc,
              child: notesListView(context),
            ));
      },
      child: blueCard(context,
          leadingSVGImage: ImageConstants.notesT,
          subtitle: 'Notes of important discussion with the sub dealer',
          title: 'Recent Notes (${bloc.details?.userNote.length ?? 0})',
          trailingSVGImage: ImageConstants.paperPen),
    );
  }

  Padding notesListView(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                "Notes",
                style:
                    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {
                      final bloc = context.read<StoreDetailBloc>();
                      showCupertinoDialog(
                          context: context,
                          builder: (c) {
                            return BlocProvider.value(
                                value: bloc,
                                child: Builder(builder: (context) {
                                  return addNoteDialogWidget(context);
                                }));
                          });
                    },
                    icon: const Icon(Icons.add)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<StoreDetailBloc, StoreDetailState>(
              builder: (context, state) {
                final bloc = context.read<StoreDetailBloc>();
                final notes = bloc.details?.userNote ?? [];
                return notes.isEmpty
                    ? const Center(child: Text("No note added"))
                    : ListView.separated(
                        itemCount: notes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) => ListTile(
                          tileColor: Theme.of(context).secondaryHeaderColor,
                          title: Text(notes[index].note),
                          trailing: IconButton(
                              onPressed: () => bloc.add(
                                  DeleteNoteStoreDetailEvent(
                                      notes[index].noteId)),
                              icon: const Icon(Icons.delete)),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding feebackListView(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Feedbacks",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<StoreDetailBloc, StoreDetailState>(
              builder: (context, state) {
                final bloc = context.read<StoreDetailBloc>();

                return bloc.feedbackList.isEmpty
                    ? const Center(child: Text("No Feedback added"))
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: bloc.feedbackList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = bloc.feedbackList[index];
                          return ListTile(
                            isThreeLine: true,
                            tileColor: Theme.of(context).secondaryHeaderColor,
                            //leading: Image.network(item.imageUrl),
                            title: Text(item.purposeName),
                            subtitle: Text(
                                '${item.reason}\n${item.createdDate!.toStringFormat('dd-MMM-yyyy')}'),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Material addNoteDialogWidget(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: CupertinoAlertDialog(
        title: const Text("Add Note"),
        content: TextField(
          onChanged: (value) {
            context.read<StoreDetailBloc>().noteToAdd = value;
          },
          decoration: const InputDecoration(
              hintText: 'Please enter note here..',
              border: OutlineInputBorder()),
        ),
        actions: [
          CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text("Save"),
              onPressed: () {
                context.read<StoreDetailBloc>().add(SaveNoteStoreDetailEvent());
                Navigator.pop(context);
              }),
          CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }

  Padding nameAddress(BuildContext context) {
    final StoreDetailBloc bloc = context.read<StoreDetailBloc>();
    final beatPlanModel = bloc.beatPlanModel;
    return Padding(
      padding: EdgeInsets.all(15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(beatPlanModel.storeName,
              style: GoogleFonts.inter(
                  fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 10.h),
          Text(beatPlanModel.address,
              style: GoogleFonts.inter(
                  fontSize: 12.sp, fontWeight: FontWeight.w400)),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Beat Plan",
                style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                "${(bloc.distanceFromStore / 1000).toStringAsFixed(2)} km Away",
                style: GoogleFonts.inter(
                    fontSize: 12.sp, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Card blueCard(
    BuildContext context, {
    required String leadingSVGImage,
    required String title,
    required String subtitle,
    required String trailingSVGImage,
  }) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(leadingSVGImage),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
            SizedBox(width: 10.w),
            SvgPicture.asset(
              trailingSVGImage,
              width: 60.w,
              height: 50.h,
            )
          ],
        ),
      ),
    );
  }

  AspectRatio headerImage(BuildContext context) {
    final StoreDetailBloc bloc = context.read<StoreDetailBloc>();

    return AspectRatio(
      aspectRatio: 2,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
                imageUrl: 'https://picsum.photos/200/300',
                fit: BoxFit.fitWidth),
          ),
          Positioned.fill(
              child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6)),
                  onPressed: () {
                    if (bloc.beatPlanModel.isAlreadyMarkin) {
                      return;
                    } else if (bloc.beatPlanModel.markin) {
                      bloc.add(MarkOutStoreDetailEvent());
                    } else {
                      bloc.add(MarkInStoreDetailEvent());
                    }
                  },
                  child: Text(bloc.beatPlanModel.isAlreadyMarkin
                      ? "Visited"
                      : bloc.beatPlanModel.markin
                          ? "Mark Out"
                          : "Mark In")),
            ),
          )),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 5.h),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xffC92434),
                      borderRadius: BorderRadius.circular(5)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Text(bloc.details?.storeCategory ?? "",
                      style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () =>
                          bloc.add(ShowStoreOnMapStoreDetailEvent()),
                      icon: const Icon(Icons.location_on)),
                ),
                SizedBox(height: 5.h),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () => bloc.add(CallStoreDetailEvent()),
                    icon: SvgPicture.asset(ImageConstants.telephone),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _openCampaignSheet(BuildContext context, BeatPlanModel beatPlanModel) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Campaign",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Expanded(child: CampaignView()),
        ],
      ),
    );
  }
}

class StoreDetailCard extends StatelessWidget {
  final Widget child;

  const StoreDetailCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12)
          ],
          borderRadius: BorderRadius.circular(7.w)),
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
