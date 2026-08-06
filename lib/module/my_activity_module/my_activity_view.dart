import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:i_densfa/module/my_activity_module/model/my_activity_model.dart';
import 'package:i_densfa/module/my_activity_module/myActivity/my_activity_bloc.dart';
import 'package:i_densfa/module/my_activity_module/my_activity_repository.dart';
import 'package:i_densfa/module/ui/custom_search_bar.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:upgrader/upgrader.dart';

class MyActivityView extends StatefulWidget {
  final int? forUserId;
  final String name;
  const MyActivityView({super.key, required this.name, this.forUserId});

  @override
  MyActivityViewState createState() => MyActivityViewState();
}

class MyActivityViewState extends State<MyActivityView> {
  String _searchQuery = '';
  int _searchBarKey = 0;

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          elevation: 0,
        ),
        body: RepositoryProvider(
          create: (context) => MyActivityRepository(widget.forUserId),
          child: BlocProvider(
            create: (context) =>
                MyActivityBloc(context.read())..add(GetMyAcivityEvent()),
            child: BlocConsumer<MyActivityBloc, MyActivityState>(
              listenWhen: (previous, current) => current is MyActivityShowSnack,
              listener: (context, state) {
                if (state is MyActivityShowSnack) {
                  context.showSnackBarMessage(state.message);
                }
              },
              buildWhen: (previous, current) => current is! MyActivityShowSnack,
              builder: (context, state) {
                final bloc = context.read<MyActivityBloc>();
                final theme = Theme.of(context);
                final cs = theme.colorScheme;

                Widget bodyChild;
                if (_searchQuery.trim().isNotEmpty && bloc.activityList.isEmpty) {
                  bodyChild = _EmptySearchBody(
                    query: _searchQuery,
                    onClear: () {
                      setState(() {
                        _searchQuery = '';
                        _searchBarKey++;
                      });
                      bloc.add(SearchActivityEvent(''));
                    },
                  );
                } else if (bloc.activityList.isEmpty) {
                  bodyChild = _EmptyRetryBody(
                    onRetry: () => bloc.add(GetMyAcivityEvent()),
                  );
                } else {
                  bodyChild = RefreshIndicator(
                    onRefresh: () async {
                      bloc.add(GetMyAcivityEvent());
                    },
                    child: AnimationLimiter(
                      child: ListView.separated(
                        itemCount: bloc.activityList.length,
                        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 20.h),
                        physics: const AlwaysScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) =>
                            AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 420),
                          child: SlideAnimation(
                            verticalOffset: 36.0,
                            child: FadeInAnimation(
                              child: MyActiviyItemView(
                                index,
                                bloc.activityList[index],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
                      child: Material(
                        elevation: 0,
                        color: cs.surfaceContainerHighest
                            .withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10.w, 10.h, 6.w, 10.h),
                          child: Column(
                            children: [
                              CustomSearchBar(
                                key: ValueKey(_searchBarKey),
                                onChange: (String value) {
                                  setState(() => _searchQuery = value);
                                  bloc.add(SearchActivityEvent(value));
                                },
                                hintText: 'Search by store or activity...',
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_rounded,
                                    size: 20.sp,
                                    color: theme.primaryColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      bloc.selected.toStringFormat('dd MMMM yyyy'),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    onPressed: () async {
                                      final b = context.read<MyActivityBloc>();
                                      final anchor = b.selected;
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: anchor,
                                        firstDate: DateTime(anchor.year - 1),
                                        lastDate: DateTime(anchor.year + 1, 12, 31),
                                      );
                                      if (date != null && context.mounted) {
                                        b.add(MyActivityChangeMonth(date));
                                      }
                                    },
                                    icon: Icon(
                                      Icons.calendar_month_rounded,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: bodyChild),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySearchBody extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _EmptySearchBody({
    required this.query,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        SizedBox(height: 0.12.sh),
        Icon(
          Icons.search_off_rounded,
          size: 56.sp,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
        ),
        SizedBox(height: 16.h),
        Text(
          'No matching activity',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Nothing matches "$query". Try another keyword or clear the search.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        SizedBox(height: 20.h),
        Center(
          child: FilledButton.tonalIcon(
            onPressed: onClear,
            icon: const Icon(Icons.clear_rounded),
            label: const Text('Clear search'),
          ),
        ),
      ],
    );
  }
}

class _EmptyRetryBody extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyRetryBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        SizedBox(height: 0.12.sh),
        Icon(
          Icons.timeline_rounded,
          size: 56.sp,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
        ),
        SizedBox(height: 16.h),
        Text(
          'No activity for this day',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Pick another date or pull to refresh. If this looks wrong, try loading again.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        SizedBox(height: 20.h),
        Center(
          child: FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}

class MyActiviyItemView extends StatelessWidget {
  final int index;
  final MyActivityDataList item;

  const MyActiviyItemView(this.index, this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: cs.onSurfaceVariant,
      letterSpacing: 0.3,
    );

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ACTIVITY', style: labelStyle),
                  SizedBox(height: 4.h),
                  Text(
                    item.activityName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text('STORE', style: labelStyle),
                  SizedBox(height: 4.h),
                  Text(
                    item.storeName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18.sp,
                  color: theme.primaryColor,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.time,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
