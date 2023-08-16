import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/ui/button_views.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'bloc/my_schedule_bloc.dart';

class AddBeatPlanView extends StatelessWidget {
  const AddBeatPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocConsumer<MyScheduleBloc, MyScheduleState>(
          listener: (context, state) {
            if (state is BeatPlanUploadSuccess) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            final MyScheduleBloc bloc = context.read();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Store",
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 5),
                DropDownWithOptions(
                  options: bloc.storesList.map((e) => e.name).toList(),
                  hint: "Please select store",
                  selectedVal: context.select(
                      (MyScheduleBloc value) => value.selectedStore?.name),
                  valChanged: (value) {
                    if (value != null) {
                      bloc.selectedStore = bloc.storesList
                          .firstWhere((element) => element.name == value);
                    }
                  },
                ),
                Text("Show on date",
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 5),
                Container(
                  width: 1.sw,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: TextEditingController(
                        text: bloc.storeAddDate?.toStringFormat('dd/MM/yyyy')),
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.calendar_month_outlined),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 8, bottom: 11, top: 11, right: 8),
                        hintText: "DD/MM/YYYY"),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                ),
                Text("Reason", style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 5),
                Container(
                  width: 1.sw,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 8, bottom: 8, top: 8, right: 8),
                        hintText: "Type your reason here..."),
                    minLines: 3,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    onChanged: (value) => bloc.storeAddRemark = value,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  child: MaterialButton(
                    onPressed: () => bloc.add(BeatPlanAddEvent()),
                    color: ColorConstants.amber,
                    child: Text(
                      state is BeatPlanUploadLoadingState
                          ? "Loading..."
                          : "Submit",
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
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

  @override
  void initState() {
    reminderDateTextController.text =
        selectedDate.toStringFormat("dd MMMM yyyy HH:mm");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: Text("Add Reminder",
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 10),
            Text("Select Date", style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 5),
            Container(
              width: 1.sw,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: reminderDateTextController,
                decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.only(left: 8, bottom: 11, top: 11, right: 8),
                    hintText: "DD/MM/YYYY"),
                readOnly: true,
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SizedBox(
                      height: 0.33.sh,
                      child: CupertinoDatePicker(
                        minimumDate: DateTime.now(),
                        maximumDate:
                            DateTime.now().add(const Duration(days: 15)),
                        onDateTimeChanged: (date) {
                          selectedDate = date;
                          reminderDateTextController.text =
                              selectedDate.toStringFormat("dd MMMM yyyy HH:mm");
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Text("Title", style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 5),
            Container(
              width: 1.sw,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.only(left: 8, bottom: 8, top: 8, right: 8),
                    hintText: "Add Title"),
                maxLines: 1,
              ),
            ),
            Text("Content", style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 5),
            Container(
              width: 1.sw,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 8, bottom: 8, top: 8, right: 8),
                ),
                minLines: 3,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              child: MaterialButton(
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
                          interval:
                              selectedDate.difference(DateTime.now()).inSeconds,
                          preciseAlarm: true,
                          timeZone: await AwesomeNotifications()
                              .getLocalTimeZoneIdentifier()));
                  AppStorage().reminderCount = id;
                  if (context.mounted) {
                    context.showSnackBarMessage('Reminder added Successfully');
                    context.pop();
                  }
                },
                color: ColorConstants.amber,
                child: const Text("Submit"),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
