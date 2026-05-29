import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/campaign_module/view/campaign_view.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/module/my_store_module/my_store_repository.dart';
import 'package:i_densfa/module/my_store_module/mystore/mystore_bloc.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/module/ui/custom_search_bar.dart' show CustomSearchBar;
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/custom_paints.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:upgrader/upgrader.dart';

class MyStoreView extends StatefulWidget {
  final int? forUserId;
  const MyStoreView({super.key, this.forUserId});

  @override
  State<MyStoreView> createState() => _MyStoreViewState();
}

class _MyStoreViewState extends State<MyStoreView> {
  final searchController = TextEditingController();
  bool isDialogShowing = false;
  final userDetail = AppStorage().userDetail;
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
        upgrader:
            Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
        shouldPopScope: () => false,
        showIgnore: false,
        showLater: false,
        navigatorKey: router.routerDelegate.navigatorKey,
        child: Scaffold(
          appBar: widget.forUserId != null
              ? AppBar(title: const Text('My Stores'))
              : null,
          floatingActionButton: widget.forUserId != null 
              ? null 
              : _floatingActionButtons(),
          body: BlocProvider(
            create: (context) =>
                MystoreBloc(MyStoreRepository(widget.forUserId))
                  ..add(MyStoreUpdateData()),
            child: BlocConsumer<MystoreBloc, MystoreState>(
              listener: (context, state) {
                if (state is MyStoreShowError) {
                  context.showSnackBarMessage(state.message);
                }
              },
              builder: (context, state) {
                final bloc = context.read<MystoreBloc>();
                return RefreshIndicator(
                  onRefresh: () async => bloc.add(MyStoreUpdateData()),
                  child: ListView.separated(
                    controller: bloc.controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    itemCount: bloc.beatPlans.length + 1,
                    separatorBuilder: (context, index) =>
                        index == 0 ? const SizedBox() : const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            children: [
                              SizedBox(width: 10.w),
                              Expanded(
                                child: CustomSearchBar(
                                  onChange: (String value) {
                                    bloc.filerValue = value;
                                    bloc.isFromfilter = value.isNotEmpty;
                                    bloc.add(SearchMyStoreEvent(value));
                                  },
                                  hintText: 'Search by name,code or ID...',
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => bloc.add(SortMyStoreEvent()),
                                icon: const Icon(Icons.social_distance),
                                label: const Text("Sort"),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return _storeCardListItem(context, index - 1);
                      }
                    },
                  ),
                );

                // RefreshIndicator(
                //   onRefresh: () async => bloc.add(MyStoreUpdateData()),
                //   child: Column(
                //     children: [
                //       Padding(
                //         padding: EdgeInsets.symmetric(vertical: 10.h),
                //         child: Row(
                //           children: [
                //             SizedBox(width: 10.w),
                //             Expanded(
                //               child: CustomSearchBar(
                //                 onChange: (String value) {
                //                   bloc.filerValue=value;
                //                   bloc.isFromfilter = value.isNotEmpty;
                //                   bloc.add(SearchMyStoreEvent(value));
                //                 },
                //                 hintText: 'Search by name or ID...',
                //               ),
                //             ),
                //             TextButton.icon(
                //                 onPressed: () =>
                //                    bloc.add(SortMyStoreEvent()),
                //                 icon: const Icon(Icons.social_distance),
                //                 label: const Text("Sort")),
                //           ],
                //         ),
                //       ),
                //       Expanded(
                //         child: (state is MyStoreLoadingState)
                //             ? const Center(child: CircularProgressIndicator())
                //             : bloc.beatPlans.isEmpty
                //                 ? SingleChildScrollView(
                //                     physics:const AlwaysScrollableScrollPhysics(),
                //                     child: SizedBox(
                //                       height: 0.5.sh,
                //                       child: const Center(
                //                           child: Text("Don't have a store.")),
                //                     ),
                //                   )
                //                 : AnimationLimiter(
                //                     child: ListView.separated(
                //                        controller: bloc.controller,
                //                       padding: const EdgeInsets.all(10),
                //                       itemCount: bloc.beatPlans.length,
                //                       separatorBuilder: (context, index) =>
                //                           const SizedBox(height: 10),
                //                       itemBuilder: _storeCardListItem,
                //                     ),
                //                   ),
                //       )
                //     ],
                //   ),
                // );
              },
            ),
          ),
        ));
  }

  Widget _storeCardListItem(BuildContext context, int index) {
    final bloc = context.read<MystoreBloc>();
    final store = bloc.beatPlans[index];

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: InkWell(
            onTap: widget.forUserId == null
                ? () async {
                    if (userDetail?.userConfiguration.requiredStartDuty ==
                            true ||
                        userDetail?.configuration.requiredStartDuty == true) {
                      if (!AppStorage().isDutyStarted) {
                        context.showSnackBarMessage(
                            "Please start your Duty first");

                        return;
                      }
                    }

                    bloc.canpopbool = await bloc.canpop(store);
                    bloc.filledCampaignList.clear();
                    AppPopup.showAppBottomSheet(
                            // isDismis: false,
                            enableDrag: false,
                            context: context,
                            child: PopScope(
                                canPop: !bloc.canpopbool,
                                onPopInvokedWithResult: (value, result) async {
                                  if (value) return;

                                  //  final CampaignBloc campaignBloc = context.read<CampaignBloc>();
                                  //  bloc.filledCampaignList = campaignBloc.filledCampaignList;
                                  bloc.add(GetCampaignFilledEvent(store));
                                  final canPop = await bloc.canpop(store);
                                  bloc.canpopbool = canPop;
                                  // if (isDialogShowing) return;
                                  // isDialogShowing = true;
                                  if (canPop) {
                                    final response =
                                        await _showQuitWarning(context);
                                    if (response == true && context.mounted) {
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  } else {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  }

                                  // isDialogShowing = false;
                                },
                                child: _openCampaignSheet(context, store)))
                        .then((value) => {
                              bloc.add(GetCampaignFilledEvent(store)),
                            });
                  }
                : null,
            child: StoreCardView(store,
                distanceInMeters: 0.0,
                forUserId: widget.forUserId,
                bloc: bloc)),
      ),
    );
  }

  Widget _floatingActionButtons() {
    return Builder(builder: (context) {
      return SpeedDial(
        closedForegroundColor: Colors.white,
        closedBackgroundColor: Theme.of(context).primaryColor,
        openForegroundColor: Theme.of(context).primaryColor,
        openBackgroundColor: Colors.white,
        speedDialChildren: [
        if(AppStorage().userDetail?.configuration.requiredFwpStore??false)
          SpeedDialChild(
            child: const Icon(Icons.add_business),
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            label: 'Add New Retailer',
            onPressed: () async {
              final result = await context.pushNamed(AppPaths.createStore);
              if (result == true && context.mounted) {
                context.read<MystoreBloc>().add(MyStoreUpdateData());
              }
            },
          ),
          
          SpeedDialChild(
            child: const Icon(Icons.filter_list),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Filter Stores',
            onPressed: () {
              context.showSnackBarMessage('Filter feature coming soon!');
            },
          ),
        ],
        child: Icon(
          Icons.add,
          size: 30.w,
        ),
      );
    });
  }
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
        Expanded(
            child: CampaignView(
                mechanicsContact: beatPlanModel.mechanicContact,
                mechanicsName: beatPlanModel.mechanicName,
                storeId: beatPlanModel.storeId,
                from: AppPaths.tabbar,
                storeLat: beatPlanModel.latitude ?? 0.0,
                storeLong: beatPlanModel.longitude ?? 0.0)),
      ],
    ),
  );
}

Future<bool?> _showQuitWarning(BuildContext context) {
  return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            "Are you sure you want to exit from the store without completing all campaigns?"
                .toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          cancelButton: TextButton(
              onPressed: () => {
                    if (Navigator.canPop(context))
                      {Navigator.pop(context, false)}
                  },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.red),
              )),
          actions: [
            TextButton(
                onPressed: () => {
                      if (Navigator.canPop(context))
                        {Navigator.pop(context, true)}
                    },
                child:
                    const Text('Yes', style: TextStyle(color: Colors.black))),
          ],
        );
      });
}

class StoreCardView extends StatelessWidget {
  final BeatPlanModel beatPlan;
  final double distanceInMeters;
  final int? forUserId;
  final MystoreBloc bloc;
  final userDetail = AppStorage().userDetail;
  StoreCardView(this.beatPlan,
      {super.key,
      required this.distanceInMeters,
      this.forUserId,
      required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10.h, left: 40.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              EdgeInsets.only(left: 45.w, top: 15.h, bottom: 15.h, right: 15.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beatPlan.storeName,
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(beatPlan.address,
                      style: GoogleFonts.inter(fontSize: 10)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Store Id:${beatPlan.storeId}',
                          style: GoogleFonts.inter(
                              fontSize: 10.sp, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      if (distanceInMeters > 0)
                        Text(
                            '${(distanceInMeters / 1000).toStringAsFixed(2)}Km Away',
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            style: GoogleFonts.inter(fontSize: 10.sp))
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                      onPressed: forUserId == null
                          ? () async {
                              if (userDetail?.userConfiguration
                                          .requiredStartDuty ==
                                      true ||
                                  userDetail?.configuration.requiredStartDuty ==
                                      true) {
                                if (!AppStorage().isDutyStarted) {
                                  context.showSnackBarMessage(
                                      "Please start your Duty first");

                                  return;
                                }
                              }

                              context
                                  .read<MystoreBloc>()
                                  .filledCampaignList
                                  .clear();
                              AppPopup.showAppBottomSheet(
                                      context: context,
                                      child: PopScope(
                                          canPop: !bloc.canpopbool,
                                          onPopInvokedWithResult:
                                              (value, result) async {
                                            if (value) return;
                                            context.read<MystoreBloc>().add(
                                                GetCampaignFilledEvent(
                                                    beatPlan));
                                            final canpop =
                                                await bloc.canpop(beatPlan);
                                            bloc.canpopbool = canpop;
                                            if (bloc.canpopbool) {
                                              final response =
                                                  await _showQuitWarning(
                                                      context);
                                              if (response == true &&
                                                  context.mounted) {
                                                if (Navigator.canPop(context)) {
                                                  Navigator.pop(context);
                                                }
                                              }
                                            } else {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                            }
                                          },
                                          child: _openCampaignSheet(
                                              context, beatPlan)))
                                  .then((value) => {
                                        context.read<MystoreBloc>().add(
                                            GetCampaignFilledEvent(beatPlan)),
                                        bloc.add(MyStoreUpdateData())
                                      });
                            }
                          : null,
                      style: TextButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                          child: Text(
                        'View Campaign',
                        style: Theme.of(context).textTheme.titleSmall,
                      )))
                ],
              )
            ],
          ),
        ),
        Row(children: [
          const SizedBox(width: 100),
          if (beatPlan.markin)
            const NoteClip(text: 'Marked In', backColor: Colors.blue),
          if (beatPlan.campaignResponseExists||beatPlan.isAlreadyMarkin)
            const NoteClip(text: 'Visited', backColor: Colors.green),
          const Spacer(),
          NoteClip(
              text: "Store Code: ${beatPlan.storecode}", backColor: const Color(0xff7B000C)),
          const SizedBox(width: 20),
        ]),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
                margin: EdgeInsets.only(top: 10.h),
                width: 80.w,
                height: 126.h,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.w)),
                alignment: Alignment.center,
                child: Hero(
                  tag: beatPlan.pjpId,
                  child: Image.network(
                      beatPlan.storeImage1.isNotEmpty
                          ? beatPlan.storeImage1
                          : 'https://media.istockphoto.com/id/912819604/vector/storefront-flat-design-e-commerce-icon.jpg?s=612x612&w=0&k=20&c=_x_QQJKHw_B9Z2HcbA2d1FH1U1JVaErOAp2ywgmmoTI=',
                      fit: BoxFit.fitWidth,
                      errorBuilder: (context, error, stackTrace) {
    return Image.network(
      'https://media.istockphoto.com/id/912819604/vector/storefront-flat-design-e-commerce-icon.jpg?s=612x612&w=0&k=20&c=_x_QQJKHw_B9Z2HcbA2d1FH1U1JVaErOAp2ywgmmoTI=',
      fit: BoxFit.fitWidth,
    );
  }),
                )),
          ),
        ),
      ],
    );
  }
}

class NoteClip extends StatelessWidget {
  final String text;
  final Color backColor;
  const NoteClip({
    super.key,
    required this.text,
    required this.backColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        CustomPaint(
          painter: TrianglePainter(
            strokeColor: backColor,
            strokeWidth: 10,
            paintingStyle: PaintingStyle.fill,
          ),
          child: SizedBox(
            height: 10.h,
            width: 10.h,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(5)),
              color: backColor.withValues(alpha: 0.9)),
          child: Text(
            text,
            style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
