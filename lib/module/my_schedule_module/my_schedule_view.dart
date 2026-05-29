import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/my_schedule_module/add_mechanic_view.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/module/my_schedule_module/mechanic_visit_model.dart';
import 'package:i_densfa/module/my_schedule_module/my_schedule_repository.dart';
import 'package:i_densfa/module/tabber_module/bloc/tabbar_bloc.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/module/ui/custom_search_bar.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utility/custom_paints.dart';
import 'add_beat_plan_view.dart' hide AddReminderView;
import 'bloc/my_schedule_bloc.dart';

class MyScheduleView extends StatefulWidget {
  final int? forUserId;
  const MyScheduleView({super.key, this.forUserId});

  @override
  State<MyScheduleView> createState() => _MyScheduleViewState();
}

class _MyScheduleViewState extends State<MyScheduleView>
    with SingleTickerProviderStateMixin {
  final searchController = TextEditingController();
  final mechanicSearchController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    mechanicSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: BlocProvider(
        create: (context) =>
            MyScheduleBloc(MyScheduleRepository(widget.forUserId))
              ..add(MyScheduleUpdateData()),
        child: Scaffold(
          appBar: widget.forUserId != null
              ? AppBar(title: const Text('Schedule'))
              : null,
          floatingActionButton: widget.forUserId != null
              ? null
              : AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    if (_tabController.index != 0) return _mechanicfloatingActionButtons();
                    return _floatingActionButtons();
                  },
                ),
          body: BlocConsumer<MyScheduleBloc, MyScheduleState>(
            listenWhen: (previous, current) =>
                current is MyScheduleSnackBarMessage ||
                current is EmptySearchTextMyScheduleState,
            listener: (context, state) {
              if (state is MyScheduleSnackBarMessage) {
                context.showSnackBarMessage(state.message);
                if (state.message
                    .toLowerCase()
                    .contains('Session Expired. Please Login again.')) {
                  final TabbarBloc tabbloc = context.read();
                  tabbloc.add(LogoutEvent());
                }
              } else if (state is EmptySearchTextMyScheduleState) {
                searchController.clear();
                mechanicSearchController.clear();
              }
            },
            builder: (context, state) {
              final MyScheduleBloc bloc = context.read();
              if (bloc.mechanicVisits.isEmpty && _tabController.index != 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_tabController.index != 0) {
                    _tabController.animateTo(0);
                  }
                });
              }
              return Column(
                children: [
                  ListTile(
                    tileColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    leading: bloc.selectedDate.isAfter(DateTime.now())
                        ? IconButton(
                            onPressed: bloc.onPreviousDateSelect,
                            icon: Icon(
                              Icons.chevron_left,
                              color: bloc.selectedDate == DateTime.now()
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                            ))
                        : const SizedBox(),
                    trailing: IconButton(
                        onPressed: bloc.onNextDateSelect,
                        icon: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).primaryColor,
                        )),
                    title: TextButton(
                        onPressed: () async {
                          var now = DateTime.now();
                          if (now.weekday == DateTime.sunday) {
                            now = now.add(const Duration(days: 1));
                          }
                          final date = await showDatePicker(
                              selectableDayPredicate: (date) =>
                                  date.weekday != DateTime.sunday,
                              context: context,
                              initialDate: now,
                              firstDate: now,
                              lastDate: DateTime(now.year, 12, 31));
                          if (date != null) {
                            bloc.add(MyScheduleDateChangeEvent(date));
                          }
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w700),
                            foregroundColor: Theme.of(context).primaryColor),
                        child: Text(
                            bloc.selectedDate.toStringFormat('dd MMM yyyy'))),
                  ),
                  Expanded(
                    child: (state is MyScheduleLoadingState)
                        ? const Center(child: CircularProgressIndicator())
                        : bloc.mechanicVisits.isEmpty
                            ? _storesTab(context, bloc, state)
                            : Column(
                                children: [
                                  _buildScheduleTabBar(context),
                                  Expanded(
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _storesTab(context, bloc, state),
                                        _mechanicsTab(context, bloc, state),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = theme.primaryColor;
    final isLight = theme.brightness == Brightness.light;
    final trackColor = //Theme.of(context).primaryColor.withValues(alpha: 0.15);
       isLight ? const Color(0xFFEEF1F4) : scheme.surface.withValues(alpha: 0.42);

    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 5.h, 8.w, 3.h),
      child: Container(
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: isLight ? 0.35 : 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.18),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          dividerHeight: 0,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.zero,
          indicator: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(50.r),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.28),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelStyle: GoogleFonts.inter(
           // fontSize: 13.sp,
            fontWeight: FontWeight.w600,
           // letterSpacing: 0.2,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            //fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            //letterSpacing: 0.2,
          ),
          labelColor: scheme.onPrimary,
          unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.58),
          tabs: const [
            Tab(text: 'Stores'),
            Tab(text: 'Mechanics'),
          ],
        ),
      ),
    );
  }

  Widget _storesTab(
      BuildContext context, MyScheduleBloc bloc, MyScheduleState state) {
    return RefreshIndicator(
      onRefresh: () async => bloc.add(MyScheduleUpdateData()),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomSearchBar(
                    onChange: (String value) {
                      bloc.add(SearchMyScheduleEvent(value));
                    },
                    hintText: 'Search by name,code or ID...',
                  ),
                ),
                TextButton.icon(
                    onPressed: () => bloc.add(SortMyScheduleEvent()),
                    icon: const Icon(Icons.social_distance),
                    label: const Text("Sort")),
              ],
            ),
          ),
          Expanded(
            child: bloc.beatPlans.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 0.5.sh,
                      child: const Center(
                          child: Text("No beat assigned yet.")),
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(10),
                      itemCount: bloc.beatPlans.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: _storeCardListItem,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  BeatPlanModel _beatPlanForMechanicVisit(
      MechanicVisitModel visit, MyScheduleBloc bloc) {
    for (final plan in bloc.beatPlans) {
      if (plan.storeId == visit.storeId) {
        return plan;
      }
    }
    return BeatPlanModel(
      pjpId:0,
      markin: visit.markin,
      isAlreadyMarkin: visit.isAlreadyMarkin,
      storeId: visit.storeId,
      pjpDate: bloc.selectedDate,
      storeName: visit.retailerName,
      storeCategory: '',
      address: visit.location,
      latitude: null,
      longitude: null,
      activeStatus: true,
      storeImage1: '',
      storecode: '',
      mobileNumber: visit.mechanicContact,
      campaignResponseExists: false,
      supervisor: '',
      formFilledBy: null,
      assignedUsers: const [],
      mechanicContact: visit.mechanicContact,
      mechanicName: visit.mechanicName
    );
  }

  Widget _mechanicsTab(
      BuildContext context, MyScheduleBloc bloc, MyScheduleState state) {
    return RefreshIndicator(
      onRefresh: () async => bloc.add(MyScheduleUpdateData()),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomSearchBar(
                    onChange: (String value) {
                      bloc.add(SearchMechanicVisitsEvent(value));
                    },
                    hintText: 'Search by mechanic name, phone, store id...',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: bloc.mechanicVisits.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 0.5.sh,
                      child: const Center(
                        child: Text('No mechanic visits for this date.'),
                      ),
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      itemCount: bloc.mechanicVisits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        final visit = bloc.mechanicVisits[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: InkWell(
                              onTap: widget.forUserId == null
                                  ? () async {
                                      final beatPlan =
                                          _beatPlanForMechanicVisit(
                                              visit, bloc);
                                      await context.pushNamed(AppPaths.store,
                                          extra: beatPlan);
                                      if (context.mounted) {
                                        bloc.add(MyScheduleUpdateData());
                                      }
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(10),
                              child: MechanicVisitCard(visit),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _storeCardListItem(BuildContext context, int index) {
    final MyScheduleBloc bloc = context.read();
    final store = bloc.beatPlans[index];
    final distance = bloc.distanceFromStore(store);
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: InkWell(
            onTap: widget.forUserId == null
                ? () async {
                    await context.pushNamed(AppPaths.store,
                        extra: bloc.beatPlans[index]);
                    bloc.add(MyScheduleUpdateData());
                  }
                : null,
            child: StoreCardView(store, distanceInMeters: distance)),
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
            backgroundColor: Colors.amber,
            label: 'Add New Retailer',
            onPressed: () async {
              final result = await context.pushNamed(AppPaths.createStore);
              if (result == true && context.mounted) {
                context.read<MyScheduleBloc>().add(MyScheduleUpdateData());
              }
            },
          ),
           SpeedDialChild(
            child: const Icon(Icons.store),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Add Beat Plan',
            onPressed: () {
              var bloc = context.read<MyScheduleBloc>();
              bloc.selectedStore = null;
              bloc.storeAddRemark = "";
              bloc.storeAddDate = null;
              AppPopup.showAppBottomSheet(
                context: context,
                child: BlocProvider.value(
                  value: bloc..add(GetAllStoresListEvent()),
                  child: const AddBeatPlanView(),
                ),
              );
            },
          ),
           SpeedDialChild(
            child: const Icon(Icons.article),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Add Reminder',
            onPressed: () {
              AppPopup.showAppBottomSheet(
                context: context,
                child: const AddReminderView(),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.pending_actions),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Schedule Visit',
            onPressed: () {
              final plans = context.read<MyScheduleBloc>().beatPlans;
              if (plans.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Don't have store to schedule visit.")));
              } else {
                context.pushNamed(AppPaths.scheduleVisit, extra: plans);
              }
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

   Widget _mechanicfloatingActionButtons() {
    return Builder(builder: (context) {
      return SpeedDial(
        closedForegroundColor: Colors.white,
        closedBackgroundColor: Theme.of(context).primaryColor,
        openForegroundColor: Theme.of(context).primaryColor,
        openBackgroundColor: Colors.white,
        speedDialChildren: [
       
           SpeedDialChild(
            child: const Icon(Icons.store),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Add Mechanic',
            onPressed: () {
              var bloc = context.read<MyScheduleBloc>();
              bloc.selectedMechanic = null;
              bloc.storeAddRemark = "";
              bloc.storeAddDate = null;
              AppPopup.showAppBottomSheet(
                context: context,
                child: BlocProvider.value(
                  value: bloc..add(GetAllMechancicListEvent()),
                  child: const AddMechanicView(),
                ),
              );
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

class StoreCardView extends StatelessWidget {
  final BeatPlanModel beatPlan;
  final double distanceInMeters;
  const StoreCardView(this.beatPlan,{super.key, required this.distanceInMeters});

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
                        Text('Store Id : ${beatPlan.storeId}',
                              style: GoogleFonts.inter(
                                  fontSize: 10.sp, fontWeight: FontWeight.w500)),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                        
                      //      Text('Store Code : ${beatPlan.storecode}',
                      //         style: GoogleFonts.inter(
                      //             fontSize: 10.sp, fontWeight: FontWeight.w500)),
                      //   ],
                      // ),
                      const SizedBox(width: 8),
                      if (distanceInMeters > 0)
                        Text(
                            '${(distanceInMeters / 1000).toStringAsFixed(2)}Km Away',
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            style: GoogleFonts.inter(fontSize: 10.sp))
                    ],
                  ),
                  if ((beatPlan.formFilledBy ?? '').trim().isNotEmpty ||
                      (beatPlan.assignedUsers?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 6),
                    if ((beatPlan.formFilledBy ?? '').trim().isNotEmpty)
                      Text(
                        'Form filled by: ${beatPlan.formFilledBy!.trim()}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if ((beatPlan.formFilledBy ?? '').trim().isNotEmpty &&
                        (beatPlan.assignedUsers?.isNotEmpty ?? false))
                      const SizedBox(height: 2),
                    if (beatPlan.assignedUsers?.isNotEmpty ?? false)
                      Text(
                        'Assigned: ${beatPlan.assignedUsers!.join(", ")}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                  const SizedBox(height: 8),
                  FilledButton(
                      onPressed: () async {
                        await context.pushNamed(AppPaths.store,
                            extra: beatPlan);
                        if (context.mounted) {
                          context.read<MyScheduleBloc>().add(MyScheduleUpdateData());
                        }
                      },
                      style: TextButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Center(child: Text('View Store',style: Theme.of(context).textTheme.titleSmall)))
                ],
              )
            ],
          ),
        ),
        beatPlan.pjpDate.isSameDate(DateTime.now())?
        Row(children: [
          const SizedBox(width: 100),
          if (beatPlan.markin)
            const NoteClip(text: 'Marked In', backColor: Colors.blueAccent),
          if (beatPlan.isAlreadyMarkin)
            const NoteClip(text: 'Visited', backColor: Colors.green),
          const Spacer(),
          NoteClip(
              text: "Store Code: ${beatPlan.storecode}", backColor: const Color(0xff7B000C)),
          const SizedBox(width: 20),
        ]):const SizedBox(),
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
  },),
                )),
          ),
        ),
      ],
    );
  }
}

class MechanicVisitCard extends StatelessWidget {
  final MechanicVisitModel visit;

  const MechanicVisitCard(this.visit, {super.key});

  Future<void> _dialContact(String raw) async {
    final digits = raw.replaceAll(RegExp(r'\s'), '');
    if (digits.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: digits);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final hasFlags = visit.markin || visit.isAlreadyMarkin;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          margin: EdgeInsets.only(top: hasFlags ? 10.h : 0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visit.mechanicName,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6.h),
              InkWell(
                onTap: () => _dialContact(visit.mechanicContact),
                child: Row(
                  children: [
                    Icon(Icons.phone_in_talk_outlined,
                        size: 16.sp, color: Colors.green),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        visit.mechanicContact.isEmpty
                            ? '—'
                            : visit.mechanicContact,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: visit.mechanicContact.isEmpty
                              ? null
                              : Colors.green,
                          decoration: visit.mechanicContact.isEmpty
                              ? null
                              : TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                visit.retailerName,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4.h),
              Text(
                'Store Id: ${visit.storeId}',
                style: GoogleFonts.inter(fontSize: 11),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      visit.location,
                      style: GoogleFonts.inter(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (visit.segment.isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        visit.segment,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (hasFlags)
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (visit.markin)
                  const NoteClip(
                      text: 'Marked In', backColor: Colors.blueAccent),
                if (visit.isAlreadyMarkin)
                  const NoteClip(text: 'Visited', backColor: Colors.green),
              ],
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
