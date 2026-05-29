import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:i_densfa/module/leaves_module/leave/leave_bloc.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/module/ui/dialog_helper.dart';
import 'package:i_densfa/utility/extensions.dart';

class OptionalLeaveView extends StatefulWidget {
  const OptionalLeaveView({super.key});

  @override
  State<OptionalLeaveView> createState() => _OptionalLeaveViewState();
}

class _OptionalLeaveViewState extends State<OptionalLeaveView> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
        backgroundColor: cs.surface,
        body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              child: BlocConsumer<LeaveBloc, LeaveState>(
                listenWhen: (context, state) =>
                    state is OptionalLeaveStateChange ||
                    state is LeaveAppliedSuccess,
                listener: (context, state) {
                  if (state is LeaveAppliedSuccess) {
                    DialogHelper.showErrorMessage(
                        context, "Message", state.message,
                        onOkayClick: () => {
                              Navigator.pop(context),
                              Navigator.pop(context),
                            });
                  }
                },
                builder: (context, state) {
                  final bloc = context.read<LeaveBloc>();
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Center(
                          child: Container(
                            width: 36.w,
                            height: 4.h,
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: cs.onSurfaceVariant
                                  .withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Text(
                          'Optional leave',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'You can apply up to ${bloc.availabeOptionLeave} optional leave(s).',
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Material(
                          color: theme.primaryColor.withValues(alpha: 0.18),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.h, horizontal: 8.w),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Date',
                                    textAlign: TextAlign.center,
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Occasion',
                                    textAlign: TextAlign.center,
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Select',
                                    textAlign: TextAlign.center,
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          color: cs.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                            side: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.35),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AnimationLimiter(
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: bloc.optionalLeave.length,
                                itemBuilder: (c, index) =>
                                    AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                          verticalOffset: 40.0,
                                          child: FadeInAnimation(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: index.isEven
                                                    ? cs.surfaceContainerHighest
                                                        .withValues(alpha: 0.25)
                                                    : cs.primaryContainer
                                                        .withValues(alpha: 0.12),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.h),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        bloc
                                                                .optionalLeave[
                                                                    index]
                                                                .date
                                                                ?.toStringFormat(
                                                                    "dd MMM yy") ??
                                                            "",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    4.w),
                                                        child: Text(
                                                          bloc
                                                              .optionalLeave[
                                                                  index]
                                                              .occasion,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 3,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style: textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                            height: 1.3,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: bloc
                                                              .optionalLeave[
                                                                  index]
                                                              .canChange
                                                          ? Checkbox(
                                                              materialTapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .shrinkWrap,
                                                              value: bloc
                                                                          .optionalLeave[
                                                                              index]
                                                                          .canChange ==
                                                                      true
                                                                  ? bloc
                                                                      .optionalLeave[
                                                                          index]
                                                                      .isActive
                                                                  : true,
                                                              onChanged:
                                                                  (value) => {
                                                                        if (bloc
                                                                            .optionalLeave[index]
                                                                            .canChange)
                                                                          {
                                                                            bloc.add(ChangeOptionalLeaveStatus(
                                                                                index,
                                                                                value ??
                                                                                    false))
                                                                          }
                                                                      })
                                                          : Center(
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8.w,
                                                                        vertical:
                                                                            4.h),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: const Color(
                                                                          0xFF2E7D32)
                                                                      .withValues(
                                                                          alpha:
                                                                              0.12),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Text(
                                                                  'Applied',
                                                                  style: textTheme
                                                                      .labelMedium
                                                                      ?.copyWith(
                                                                    color: const Color(
                                                                        0xFF1B5E20),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )),
                                    )),
                          ),
                        ),
                        SizedBox(height: 22.h),
                        bloc.canSubit
                            ? CustomButton(
                                buttonText: 'Submit',
                                onPressed: () {
                                  if (state is! LoadingState) {
                                    bloc.add(ApplyOptionalLeave());
                                  }
                                },
                                isLoading: state is LoadingState,
                                isSuccess: state is LeaveAppliedSuccess,
                              )
                            : const SizedBox(),
                      ]);
                },
              ),
            )));
  }
}
