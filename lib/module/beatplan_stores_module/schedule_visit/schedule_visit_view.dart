import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:i_densfa/module/ui/custom_material_button.dart';

import 'bloc/schedule_visit_call_bloc.dart';

class ScheduleVisitView extends StatelessWidget {
  const ScheduleVisitView({super.key});

  @override
  Widget build(BuildContext context) {
    final type = context.read<ScheduleVisitCallBloc>().schedulingFor;
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Schedule Visit or Call',
        style: Theme.of(context).textTheme.titleSmall,
      )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl(
                  padding: const EdgeInsets.all(0),
                  thumbColor: Theme.of(context).colorScheme.background,
                  groupValue: context.select(
                      (ScheduleVisitCallBloc value) => value.schedulingFor),
                  children: const {
                    SchuduleType.visit: Center(child: Text("VISIT")),
                    SchuduleType.call: Center(child: Text("CALL"))
                  },
                  onValueChanged: (val) {
                    if (val != null) {
                      context
                          .read<ScheduleVisitCallBloc>()
                          .add(ScheduleTypeChangeEvent(val));
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type == SchuduleType.visit
                          ? "Visit date*"
                          : "Call date*"),
                      TextField(
                        readOnly: true,
                        onTap: () {
                          showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year, 12, 31));
                        },
                        decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.calendar_month_outlined),
                            hintText: 'DD/MM/YYYY'),
                      ),
                    ],
                  )),
                  if (type == SchuduleType.visit) ...[
                    const SizedBox(width: 10),
                    Expanded(child: selectStore(context))
                  ]
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Start time"),
                      TextField(
                        readOnly: true,
                        onTap: () {
                          showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                        },
                        decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.watch_later_outlined),
                            hintText: '00:00 PM'),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("End time"),
                      TextField(
                        readOnly: true,
                        onTap: () {
                          showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                        },
                        decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.watch_later_outlined),
                            hintText: '00:00 PM'),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            const Text("Agenda"),
            const TextField(
              minLines: 5,
              maxLines: 10,
              maxLength: 256,
              decoration: InputDecoration(
                  hintText: 'Type here (max 256 characters allowed)'),
            ),
            const SizedBox(height: 20),

            CustomMaterialButton(buttonText: "Save", onPressed: () => {}),
            // TextButton(
            //     onPressed: () {},
            //     child: const SizedBox(
            //         height: 40, child: Center(child: Text("SAVE"))))
          ],
        ),
      ),
    );
  }

  Column selectStore(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Select Store*"),
        TextField(
          readOnly: true,
          // onTap: () async {
          //   final selectedItem = await AppPopup.showAppBottomSheet(
          //     context: context,
          //     child: ListView.separated(
          //       shrinkWrap: true,
          //       padding: const EdgeInsets.all(10),
          //       itemCount: 10,
          //       separatorBuilder: (context, index) =>
          //           const SizedBox(height: 10),
          //       itemBuilder: (context, index) => InkWell(
          //           onTap: () {
          //             context.pop('name');
          //           },
          //           child: StoreCardView()),
          //     ),
          //   );

          //   debugPrint(selectedItem);
          // },
          decoration: InputDecoration(
              suffixIcon: Icon(Icons.keyboard_arrow_down),
              hintText: 'Store Name'),
        ),
      ],
    );
  }
}
