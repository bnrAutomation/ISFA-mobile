import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:i_densfa/module/promoter_module/feedback/feedback_view.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';
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
import 'package:upgrader/upgrader.dart';

import '../../utility/app_constants.dart';
import 'bloc/store_detail_bloc.dart';

class StoreDetailView extends StatelessWidget {
  const StoreDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDialogShowing = false;
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: BlocBuilder<StoreDetailBloc, StoreDetailState>(
        builder: (context, state) {
          final bloc = context.read<StoreDetailBloc>();

          return PopScope(
            canPop: !bloc.beatPlanModel.markin,
            onPopInvokedWithResult: (value, result) async {
              if (kDebugMode) {
                debugPrint("Markin status : ${bloc.beatPlanModel.markin}");
              }
              if (bloc.beatPlanModel.markin) {
                if (isDialogShowing) return;
                isDialogShowing = true;
                final response = await _showQuitWarning(context);
                if (response == true &&
                    context.mounted &&
                    Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }
              isDialogShowing = false;
            },
            child: Scaffold(
              floatingActionButton: _floatingButtons(bloc),
              appBar: AppBar(
                title: const Text('Store'),
                centerTitle: false,
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  bloc.add(GetCampaignFilledEvent());
                  bloc.add(GetStoreDetailsEvent());
                  await bloc.stream.firstWhere(
                    (s) =>
                        s is LoadedStoreDetailState ||
                        s is StoreDetailToastMessageState,
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: BlocConsumer<StoreDetailBloc, StoreDetailState>(
                  listenWhen: (previous, current) =>
                      current is StoreDetailToastMessageState ||
                      current is CampaignsLoadedStoreDetailState,
                  listener: (context, state) async {
                    if (state is StoreDetailToastMessageState) {
                      context.showSnackBarMessage(state.message);
                    }

                    //  else if (state is CampaignsLoadedStoreDetailState) {

                    //   final StoreDetailBloc bloc = context.read();
                    //   AppPopup.showAppBottomSheet(
                    //           context: context,
                    //           child: _openCampaignSheet(context, bloc.beatPlanModel))
                    //       .then((value) => {bloc.add(GetCampaignFilledEvent())});
                    // }
                  },
                  builder: (context, state) {
                    final StoreDetailBloc bloc =
                        context.read<StoreDetailBloc>();
                    return state is MarkingLoadingStoreDetailState
                        ? SizedBox(
                            height: 1.sh - 10.h,
                            child: const Center(
                                child: CircularProgressIndicator()))
                        : Column(
                            children: [
                              headerImage(context),
                              nameAddress(context),
                              !bloc.beatPlanModel.markin
                                  ? Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          15.w, 0.h, 15.w, 12.h),
                                      child: Container(
                                        width: 1.sw,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.w, vertical: 14.h),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius:
                                              BorderRadius.circular(14.r),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withValues(alpha: 0.55),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                  alpha: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? 0.06
                                                      : 0.18),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 36.r,
                                              height: 36.r,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                Icons.lock_outline,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Mark-in required',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  Text(
                                                    'To access campaign forms, please mark-in first.',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                    alpha:
                                                                        0.75)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: 1.sw,
                                      height: 1.sh,
                                      child: CampaignView(
                                        retailerName: bloc.beatPlanModel.storeName,
                                          mechanicsContact: bloc.beatPlanModel.mechanicContact,
                                          mechanicsName: bloc.beatPlanModel.mechanicName,
                                          storeId: bloc.beatPlanModel.storeId,
                                          from: AppPaths.store,
                                          storeLat:
                                              bloc.beatPlanModel.latitude ??
                                                  0.0,
                                          storeLong:
                                              bloc.beatPlanModel.longitude ??
                                                  0.0),
                                    ),

                              // blueCard(context,
                              //     leadingSVGImage: ImageConstants.miniCalendar,
                              //     subtitle: 'Scheduled visits & Calls',
                              //     title: '28 Feb 2023',
                              //     trailingSVGImage: ImageConstants.visitsCalls),
                              // InkWell(
                              //   onTap: () {
                              //     AppPopup.showAppBottomSheet(
                              //         context: context,
                              //         child: BlocProvider.value(
                              //           value: context.read<StoreDetailBloc>()
                              //             ..add(GetFeedbackEvent()),
                              //           child: feedbackListView(context),
                              //         ));
                              //   },
                              //   child: blueCard(context,
                              //       leadingSVGImage: ImageConstants.feedbackWhite,
                              //       title: 'Feedback',
                              //       subtitle:
                              //           'Feedback that you had given before to this store.',
                              //       trailingSVGImage: ImageConstants.feedbackWhite),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(vertical: 10.0),
                              //   child: recentNote(context),
                              // ),

                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: StoreDetailCard(
                              //         child: Row(
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //           children: [
                              //             SvgPicture.asset(ImageConstants.statistic),
                              //             const SizedBox(width: 8),
                              //             Column(
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               children: [
                              //                 Text("Stage",
                              //                     style: Theme.of(context)
                              //                         .textTheme
                              //                         .bodyMedium),
                              //                 Text("Select Stage",
                              //                     style: GoogleFonts.inter(
                              //                         fontSize: 10.sp,
                              //                         color:
                              //                             const Color(0xff278BBC))),
                              //               ],
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //     Expanded(
                              //       child: StoreDetailCard(
                              //         child: Row(
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //           children: [
                              //             SvgPicture.asset(ImageConstants.stars),
                              //             const SizedBox(width: 8),
                              //             Column(
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.start,
                              //               children: [
                              //                 Text("Class",
                              //                     style: Theme.of(context)
                              //                         .textTheme
                              //                         .bodyMedium),
                              //                 Text(
                              //                   "Select Class",
                              //                   style: GoogleFonts.inter(
                              //                       fontSize: 10.sp,
                              //                       color: const Color(0xff278BBC)),
                              //                 )
                              //               ],
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
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
                              //         Text("Campaign, 28 Feb 2023",
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
                            ],
                          );
                  },
                ),
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _floatingButtons(StoreDetailBloc bloc) {
    return BlocBuilder<StoreDetailBloc, StoreDetailState>(
      builder: (context, state) {
        return !bloc.beatPlanModel.markin
            ? const SizedBox.shrink()
            : SpeedDial(
                speedDialChildren: [
                    SpeedDialChild(
                      child: const Icon(Icons.note_add),
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      label: 'Notes',
                      onPressed: () {
                        AppPopup.showAppBottomSheet(
                            context: context,
                            child: BlocProvider.value(
                              value: bloc,
                              child: notesListView(context),
                            ));
                      },
                    ),
                    // SpeedDialChild(
                    //   child: const Icon(Icons.campaign),
                    //   foregroundColor: Colors.white,
                    //   backgroundColor: Theme.of(context).primaryColor,
                    //   label: 'Campaign',
                    //   onPressed: () => bloc.add(GotoCampaignEvent()),
                    //   closeSpeedDialOnPressed: false,
                    // ),

                    SpeedDialChild(
                      child: const Icon(Icons.feedback),
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      label: 'Feedback',
                      onPressed: () {
                        AppPopup.showAppBottomSheet(
                            context: context,
                            child: BlocProvider.value(
                              value: context.read<StoreDetailBloc>()
                                ..add(GetFeedbackEvent()),
                              child: feedbackListView(context),
                            ));
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
                    icon: const Icon(
                      Icons.add,
                      color: Colors.green,
                    )),
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
                        cacheExtent: 200, // Cache items for smooth scrolling
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) => ListTile(
                          tileColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.2),
                          title: Text(notes[index].note),
                          trailing: IconButton(
                              onPressed: () => bloc.add(
                                  DeleteNoteStoreDetailEvent(
                                      notes[index].noteId)),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              )),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding feedbackListView(BuildContext context) {
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
                "Feedbacks",
                style:
                    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {
                      final bloc = context.read<StoreDetailBloc>();
                      final storeDetail = bloc.details;
                      if (storeDetail != null) {
                        AppPopup.showAppBottomSheet(
                          context: context,
                          child: FeedbackView(storeName: storeDetail.name),
                        ).then((val) => {bloc.add(GetFeedbackEvent())});
                      }
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.green,
                    )),
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<StoreDetailBloc, StoreDetailState>(
              builder: (context, state) {
                final bloc = context.read<StoreDetailBloc>();
                final feedbackList = bloc.feedbackList;

                return feedbackList.isEmpty
                    ? const Center(child: Text("No Feedback added"))
                    : ListView.separated(
                        shrinkWrap: true,
                        cacheExtent: 200, // Cache items for smooth scrolling
                        itemCount: feedbackList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = feedbackList[index];
                          return ListTile(
                            isThreeLine: true,
                            tileColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.2),
                            leading: item.imageUrl == null ||
                                    (item.imageUrl ?? "").isEmpty
                                ? Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: item.imageUrl?.trim() ?? "",
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
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
      child: AlertDialog(
        title: const Text("Add Note"),
        content: TextField(
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp('(’|‘|”|“||<|>|)')),
          ],
          maxLines: 5,
          maxLength: 150,
          onChanged: (value) {
            context.read<StoreDetailBloc>().noteToAdd = value;
          },
          decoration: const InputDecoration(
              hintText: 'Please enter note here..',
              border: OutlineInputBorder()),
        ),
        actions: [
          MaterialButton(
              padding: EdgeInsets.zero,
              child: const Text("Save"),
              onPressed: () {
                context.read<StoreDetailBloc>().add(SaveNoteStoreDetailEvent());
                Navigator.pop(context);
              }),
          MaterialButton(
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
      padding: EdgeInsets.fromLTRB(15.w, 12.h, 15.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: "${bloc.beatPlanModel.pjpId}_${beatPlanModel.storeName}",
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "${beatPlanModel.storeName}${bloc.beatPlanModel.isAlreadyMarkin ? " (Visited)" : ""}",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ),
                if (bloc.beatPlanModel.isAlreadyMarkin)
                  Container(
                    margin: EdgeInsets.only(left: 10.w, top: 2.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      'Visited',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Hero(
            tag: "${bloc.beatPlanModel.pjpId}_${beatPlanModel.address}",
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    beatPlanModel.address,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.78),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
              if (bloc.distanceFromStore > 0)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    "${(bloc.distanceFromStore / 1000).toStringAsFixed(2)} km away",
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          if ((beatPlanModel.formFilledBy ?? '').trim().isNotEmpty ||
              (beatPlanModel.assignedUsers?.isNotEmpty ?? false)) ...[
            SizedBox(height: 8.h),
            // if ((beatPlanModel.formFilledBy ?? '').trim().isNotEmpty)
            //   Text(
            //     'Form filled by: ${beatPlanModel.formFilledBy!.trim()}',
            //     style: GoogleFonts.inter(
            //       fontSize: 11.sp,
            //       fontWeight: FontWeight.w500,
            //     ),
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            if ((beatPlanModel.formFilledBy ?? '').trim().isNotEmpty &&
                (beatPlanModel.assignedUsers?.isNotEmpty ?? false))
              SizedBox(height: 4.h),
            if (beatPlanModel.assignedUsers?.isNotEmpty ?? false)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      size: 16.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Assigned: ${beatPlanModel.assignedUsers!.join(", ")}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (bloc.details?.formFilled != null) ...[
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.65)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(2),
                },
                border: TableBorder.symmetric(
                  inside: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.65)),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.08),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        child: Text(
                          'Filled By',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        child: Text(
                          'Filled Date/Time',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        child: Text(
                          bloc.details!.formFilled!.filledBy,
                          style: GoogleFonts.inter(fontSize: 11.sp),
                          softWrap: true,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        child: Builder(builder: (context) {
                          final raw = bloc.details!.formFilled!.filledDateTime;
                          final dt = DateTime.tryParse(raw);
                          final display = dt == null
                              ? raw
                              : dt.toLocal().toStringFormat('dd MMM yyyy, hh:mm a');
                          return Text(
                            display,
                            style: GoogleFonts.inter(fontSize: 11.sp),
                            softWrap: true,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

  BlocConsumer<StoreDetailBloc, StoreDetailState> headerImage(
      BuildContext context) {
    return BlocConsumer<StoreDetailBloc, StoreDetailState>(
      listenWhen: (previous, current) =>
          current is StoreDetailTakeMarkinImage ||
          current is StoreDetailTakeMarkOutImage ||
          current is StoreDetailToastMessageState ||
          current is ChangeState,
      listener: (context, state) async {
        final bloc = context.read<StoreDetailBloc>();
        if (state is StoreDetailTakeMarkinImage) {
          String? path = await context.pushNamed(AppPaths.appcamera,
              pathParameters: {'from': "markinout"});
          bloc.loading = false;
          if (path == null || path.isEmpty) {
            bloc.add(ChangeStateEvent());
            context.showSnackBarMessage('Please click image');
          } else {
            bloc.add(MarkingWithImage(XFile(path)));
          }
        }
        if (state is StoreDetailTakeMarkOutImage) {
          String? path = await context.pushNamed(AppPaths.appcamera,
              pathParameters: {'from': "markinout"});
          bloc.loading = false;
          if (path == null || path.isEmpty) {
            bloc.add(ChangeStateEvent());
            context.showSnackBarMessage('Please click image');
          } else {
            bloc.add(MarkOutWithImage(XFile(path)));
          }
        }
      },
      builder: (context, state) {
        final bloc = context.read<StoreDetailBloc>();
        return AspectRatio(
          aspectRatio: 2,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Positioned.fill(
                child: Hero(
                  tag: bloc.beatPlanModel.pjpId,
                  child: CachedNetworkImage(
                    imageUrl: bloc.beatPlanModel.storeImage1.isNotEmpty
                        ? bloc.beatPlanModel.storeImage1
                        : 'https://picsum.photos/200/300',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => CachedNetworkImage(
                      imageUrl:
                          'https://media.istockphoto.com/id/912819604/vector/storefront-flat-design-e-commerce-icon.jpg?s=612x612&w=0&k=20&c=_x_QQJKHw_B9Z2HcbA2d1FH1U1JVaErOAp2ywgmmoTI=',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child:
                              Icon(Icons.store, size: 50, color: Colors.grey),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child:
                              Icon(Icons.store, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.02),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              bloc.beatPlanModel.pjpDate.isSameDate(DateTime.now())
                  ? Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 10.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: bloc.loading ? null : () {
                                      if (AppStorage()
                                              .userDetail
                                              ?.configuration
                                              .requiredDoubleMarkIn ??
                                          false) {
                                        if (bloc.beatPlanModel.markin) {
                                          bloc.add(
                                              MarkOutStoreDetailEvent(context));
                                        } else {
                                          bloc.add(
                                              MarkInStoreDetailEvent(context));
                                        }
                                      } else {
                                        if (bloc
                                            .beatPlanModel.isAlreadyMarkin) {
                                           context.showSnackBarMessage("Already Visited");
                                          return;
                                        } else if (bloc.beatPlanModel.markin) {
                                          bloc.add(
                                              MarkOutStoreDetailEvent(context));
                                        } else {
                                          bloc.add(
                                              MarkInStoreDetailEvent(context));
                                        }
                                      }
                                    },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (bloc.loading) ...[
                                    SizedBox(
                                      width: 16.r,
                                      height: 16.r,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                  ] else ...[
                                    Icon(
                                      bloc.beatPlanModel.markin
                                          ? Icons.logout
                                          : Icons.login,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                  ],
                                  Text(
                                    bloc.loading
                                        ? "Loading..."
                                        : bloc.beatPlanModel.markin
                                            ? "Mark Out"
                                            : "Mark In",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 5.h),
                    (bloc.details?.storeCode ?? "").isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            child: Text(
                                "Store Code\n${(bloc.details?.storeCode ?? "NA")}",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black)),
                          )
                        : const SizedBox.shrink(),
                    const Spacer(),
                    _QuickActionFab(
                      icon: Icons.location_on,
                      label: 'Map',
                      onTap: () => bloc.add(ShowStoreOnMapStoreDetailEvent()),
                    ),
                    SizedBox(height: 5.h),
                    _QuickActionFab(
                      icon: Icons.call_outlined,
                      label: 'Call',
                      onTap: () => bloc.add(CallStoreDetailEvent()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showQuitWarning(BuildContext context) {
    return showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(
              "You have not mark-out.\nPlease mark-out before proceeding."
                  .toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            cancelButton: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.red),
                )),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child:
                      const Text('Yes', style: TextStyle(color: Colors.black))),
            ],
          );
        });
  }

  // Widget _openCampaignSheet(BuildContext context, BeatPlanModel beatPlanModel) {
  //   final textTheme = Theme.of(context).textTheme;
  //   return Padding(
  //     padding: const EdgeInsets.all(10),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.max,
  //       children: [
  //         Text(
  //           "Campaign",
  //           style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 10),
  //         Expanded(
  //             child: CampaignView(
  //                 storeId: beatPlanModel.storeId, from: AppPaths.store,storeLat:beatPlanModel.latitude??0.0,storeLong:beatPlanModel.longitude??0.0)),
  //       ],
  //     ),
  //   );
  // }
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
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.07), blurRadius: 12)
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

class _QuickActionFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionFab({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: Theme.of(context).brightness == Brightness.light ? 4 : 2,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 46.r,
            height: 46.r,
            child: Icon(icon, color: primary),
          ),
        ),
      ),
    );
  }
}
