import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/module/my_schedule_module/my_schedule_repository.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

import '../../utility/custom_paints.dart';
import 'add_beat_plan_view.dart';
import 'bloc/my_schedule_bloc.dart';

class MyScheduleView extends StatefulWidget {
  final int? forUserId;
  const MyScheduleView({super.key, this.forUserId});

  @override
  State<MyScheduleView> createState() => _MyScheduleViewState();
}

class _MyScheduleViewState extends State<MyScheduleView> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MyScheduleBloc(MyScheduleRepository(widget.forUserId))
            ..add(MyScheduleUpdateData()),
      child: Scaffold(
        appBar: widget.forUserId != null
            ? AppBar(title: const Text('Schedule'))
            : null,
        floatingActionButton:
            widget.forUserId != null ? null : _floatingActionButtons(context),
        body: BlocConsumer<MyScheduleBloc, MyScheduleState>(
          listenWhen: (previous, current) =>
              current is MyScheduleSnackBarMessage ||
              current is EmptySearchTextMyScheduleState,
          listener: (context, state) {
            if (state is MyScheduleSnackBarMessage) {
              context.showSnackBarMessage(state.message);
            } else if (state is EmptySearchTextMyScheduleState) {
              searchController.clear();
            }
          },
          builder: (context, state) {
            final MyScheduleBloc bloc = context.read();
            return Column(
              children: [
                ListTile(
                  tileColor: const Color(0xff278BBC).withOpacity(0.2),
                  leading: bloc.selectedDate.isAfter(DateTime.now())
                      ? IconButton(
                          onPressed: bloc.onPreviousDateSelect,
                          icon: Icon(
                            Icons.chevron_left,
                            color: bloc.selectedDate == DateTime.now()
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                          ))
                      : const SizedBox(),
                  trailing: IconButton(
                      onPressed: bloc.onNextDateSelect,
                      icon: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
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
                          foregroundColor:
                              Theme.of(context).colorScheme.primary),
                      child: Text(
                          bloc.selectedDate.toStringFormat('dd MMM yyyy'))),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => bloc.add(MyScheduleUpdateData()),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            children: [
                              SizedBox(width: 10.w),
                              Expanded(
                                child: SearchBar(
                                    leading: const Icon(Icons.search,
                                        color: Colors.black),
                                    hintText: 'Search by name or ID...',
                                    side: MaterialStateProperty.all(
                                        const BorderSide(
                                            width: 1.0, color: Colors.black)),
                                    controller: searchController,
                                    elevation: MaterialStateProperty.all(0.0),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    onChanged: (value) =>
                                        bloc.add(SearchMyScheduleEvent(value))),
                              ),
                              TextButton.icon(
                                  onPressed: () =>
                                      bloc.add(SortMyScheduleEvent()),
                                  icon: const Icon(Icons.social_distance),
                                  label: const Text("Sort")),
                            ],
                          ),
                        ),
                        Expanded(
                          child: (state is MyScheduleLoadingState)
                              ? const Center(child: CircularProgressIndicator())
                              : bloc.beatPlans.isEmpty
                                  ? SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: SizedBox(
                                        height: 0.5.sh,
                                        child: const Center(
                                            child: Text("No data")),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(10),
                                      itemCount: bloc.beatPlans.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final store = bloc.beatPlans[index];
                                        final distance =
                                            bloc.distanceFromStore(store);
                                        return InkWell(
                                            onTap: widget.forUserId == null
                                                ? () {
                                                    context.pushNamed(
                                                        AppPaths.store,
                                                        extra: bloc
                                                            .beatPlans[index]);
                                                  }
                                                : null,
                                            child: StoreCardView(store,
                                                distanceInMeters: distance));
                                      },
                                    ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  SpeedDial _floatingActionButtons(BuildContext context) {
    return SpeedDial(
        speedDialChildren: [
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
            child: const Icon(Icons.store),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Add beat plan',
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
          // SpeedDialChild(
          //   child: const Icon(Icons.pending_actions),
          //   foregroundColor: Colors.white,
          //   backgroundColor: Theme.of(context).primaryColor,
          //   label: 'Schedule Visit',
          //   onPressed: () {
          //     final plans = context.read<MyScheduleBloc>().beatPlans;
          //     if (plans.isEmpty) {
          //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //           content: Text("Don't have store to schedule visit.")));
          //     } else {
          //       context.pushNamed(AppPaths.scheduleVisit, extra: plans);
          //     }
          //   },
          // ),
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
}

class StoreCardView extends StatelessWidget {
  final BeatPlanModel beatPlan;
  final double distanceInMeters;
  const StoreCardView(this.beatPlan,
      {super.key, required this.distanceInMeters});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10.h, left: 40.w),
          decoration: BoxDecoration(
            color: const Color(0xffBFD1DF),
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
                      onPressed: () =>
                          context.pushNamed(AppPaths.store, extra: beatPlan),
                      style: TextButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: Text('View Store',
                            style: GoogleFonts.inter(
                                fontSize: 10, color: Colors.white)),
                      ))
                ],
              )
            ],
          ),
        ),
        Row(children: [
          const SizedBox(width: 100),
          if (beatPlan.markin)
            const NoteClip(text: 'Marked In', backColor: Colors.green),
          if (beatPlan.isAlreadyMarkin)
            const NoteClip(text: 'Visited', backColor: Colors.green),
          const Spacer(),
          // NoteClip(
          //     text: beatPlan.storecode, backColor: const Color(0xff7B000C)),
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
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6.w)),
                alignment: Alignment.center,
                child: Image.network(
                    'https://media.istockphoto.com/id/912819604/vector/storefront-flat-design-e-commerce-icon.jpg?s=612x612&w=0&k=20&c=_x_QQJKHw_B9Z2HcbA2d1FH1U1JVaErOAp2ywgmmoTI=',
                    fit: BoxFit.fitWidth)),
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
              color: backColor.withOpacity(0.9)),
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
