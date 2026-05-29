import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/ui/button_views.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/module/ui/speech_input_widgets.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'bloc/my_schedule_bloc.dart';

class AddBeatPlanView extends StatelessWidget {
  const AddBeatPlanView({super.key});

  InputDecoration _fieldDecoration(BuildContext context, String hint,
      {Widget? suffix}) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.dividerColor.withValues(alpha: 0.65),
      ),
    );
    return InputDecoration(
      suffixIcon: suffix,
      hintText: hint,
      filled: true,
      fillColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
        child: BlocConsumer<MyScheduleBloc, MyScheduleState>(
          listener: (context, state) {
            if (state is BeatPlanUploadSuccess) {
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
            }
          },
          builder: (context, state) {
            final MyScheduleBloc bloc = context.read();
            return Padding(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    'Add beat plan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Select a store and date to add it to your schedule.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Store',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  DropDownSearchWidget<String>(
                    filterFn: (items, value) =>
                        items
                            ?.trim()
                            .toLowerCase()
                            .contains(value.trim().toLowerCase()) ??
                        false,
                    listItemWidget: (userItems) => Text(
                      userItems ?? "NA",
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    selectedWidget: Text(
                      context.select((MyScheduleBloc value) =>
                              value.selectedStore?.name) ??
                          "Please select store",
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    enabled: true,
                    options: bloc.storesList.map((e) => e.name).toList(),
                    hint: "Please select store",
                    selectedVal: context.select(
                        (MyScheduleBloc value) => value.selectedStore?.name),
                    valChanged: (value) {
                      if (value != null) {
                        bloc.selectedStore = bloc.storesList
                            .firstWhere((element) => element.name == value);
                        bloc.add(StateChangeEvent());
                      }
                    },
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Show on date',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: TextEditingController(
                        text: bloc.storeAddDate
                            ?.toStringFormat('dd/MM/yyyy')),
                    decoration: _fieldDecoration(
                      context,
                      'DD/MM/YYYY',
                      suffix: Icon(
                        Icons.calendar_month_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Reason',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SpeechEnabledTextFormField(
                    decoration: _fieldDecoration(
                      context,
                      'Type your reason here…',
                    ),
                    minLines: 3,
                    maxLines: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                          RegExp("[<>()?/{}^:]"))
                    ],
                    keyboardType: TextInputType.multiline,
                    onChanged: (value) => bloc.storeAddRemark = value,
                  ),
                  SizedBox(height: 18.h),
                  CustomButton(
                    buttonText: "Add Beat",
                    onPressed: () {
                      context.hideKeyboard();
                      bloc.add(BeatPlanAddEvent());
                    },
                    isLoading: state is BeatPlanUploadLoadingState,
                    isSuccess: state is BeatPlanUploadSuccess,
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(now.year, 12, 31));
    if (date != null && context.mounted) {
      context.read<MyScheduleBloc>().add(AddBeatPlanDateSelected(date));
    }
  }
}

class AddReminderView extends StatefulWidget {
  const AddReminderView({super.key});

  @override
  State<AddReminderView> createState() => _AddReminderViewState();
}

class _AddReminderViewState extends State<AddReminderView> {
  final reminderDateTextController = TextEditingController();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  var selectedDate = DateTime.now().add(const Duration(minutes: 15));

  InputDecoration _fieldDecoration(BuildContext context, String hint,
      {Widget? suffix}) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.dividerColor.withValues(alpha: 0.65),
      ),
    );
    return InputDecoration(
      suffixIcon: suffix,
      hintText: hint,
      filled: true,
      fillColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
    );
  }

  @override
  void initState() {
    reminderDateTextController.text =
        selectedDate.toStringFormat("dd MMMM yyyy HH:mm");
    super.initState();
  }

  @override
  void dispose() {
    reminderDateTextController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Center(
              child: Text(
                'Add reminder',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Center(
              child: Text(
                'We will notify you at the selected time.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Select date & time',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: reminderDateTextController,
              decoration: _fieldDecoration(
                context,
                'DD/MM/YYYY',
                suffix: Icon(
                  Icons.calendar_month_rounded,
                  color: theme.primaryColor,
                ),
              ),
              readOnly: true,
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => SizedBox(
                    height: 0.33.sh,
                    child: CupertinoDatePicker(
                      minimumDate: DateTime.now(),
                      maximumDate: DateTime.now().add(const Duration(days: 15)),
                      onDateTimeChanged: (date) {
                        selectedDate = date;
                        reminderDateTextController.text =
                            selectedDate.toStringFormat(
                                "dd MMMM yyyy HH:mm");
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 18.h),
            Text(
              'Title',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: titleController,
              decoration: _fieldDecoration(context, 'Add title'),
              maxLines: 1,
            ),
            SizedBox(height: 18.h),
            Text(
              'Content',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: contentController,
              decoration: _fieldDecoration(context, 'Add details'),
              minLines: 3,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 18.h),
            CustomButton(
              buttonText: "Add Reminder",
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  context.showSnackBarMessage('Please add title');
                  return;
                }
                if (contentController.text.trim().isEmpty) {
                  context.showSnackBarMessage('Please add content');
                  return;
                }
                const channelKey = 'isfa-reminder';
                await AwesomeNotifications().setChannel(NotificationChannel(
                    channelKey: channelKey,
                    channelName: 'iSFA Reminder',
                    channelDescription: 'Manage reminders for iSFA'));
                final id = AppStorage().reminderCount + 1;
                await AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: id,
                      channelKey: channelKey,
                      title: titleController.text,
                      body: contentController.text,
                      wakeUpScreen: true,
                      category: NotificationCategory.Alarm,
                    ),
                    schedule: NotificationInterval(
                        interval: Duration(
                            seconds: selectedDate
                                .difference(DateTime.now())
                                .inSeconds),
                        preciseAlarm: true,
                        timeZone: await AwesomeNotifications()
                            .getLocalTimeZoneIdentifier()));
                AppStorage().reminderCount = id;
                if (context.mounted) {
                  context.showSnackBarMessage('Reminder added Successfully');
                  context.pop();
                }
              },
              isLoading: false,
              isSuccess: false,
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
