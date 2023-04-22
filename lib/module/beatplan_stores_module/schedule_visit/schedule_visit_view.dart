import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';

import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'bloc/schedule_visit_call_bloc.dart';

class ScheduleVisitView extends StatelessWidget {
  const ScheduleVisitView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ScheduleVisitCallBloc>();
    final type = bloc.schedulingFor;
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Schedule Visit', // or Call',
        style: Theme.of(context).textTheme.titleSmall,
      )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocListener<ScheduleVisitCallBloc, ScheduleVisitCallState>(
          listenWhen: (previous, current) =>
              current is ScheduleVisitCallSnackBar ||
              current is ScheduleVisitCallSuccessState,
          listener: (context, state) {
            if (state is ScheduleVisitCallSnackBar) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ScheduleVisitCallSuccessState) {
              Navigator.pop(context);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(
              //   width: double.infinity,
              //   child: CupertinoSlidingSegmentedControl(
              //       padding: const EdgeInsets.all(0),
              //       thumbColor: Theme.of(context).colorScheme.background,
              //       groupValue: context.select(
              //           (ScheduleVisitCallBloc value) => value.schedulingFor),
              //       children: const {
              //         SchuduleType.visit: Center(child: Text("VISIT")),
              //         SchuduleType.call: Center(child: Text("CALL"))
              //       },
              //       onValueChanged: (val) {
              //         if (val != null) {
              //           context
              //               .read<ScheduleVisitCallBloc>()
              //               .add(ScheduleTypeChangeEvent(val));
              //         }
              //       }),
              // ),
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
                          controller: TextEditingController(
                              text: bloc.selectedDate
                                  ?.toStringFormat('dd/mm/yyyy')),
                          onTap: () async {
                            final now = DateTime.now();
                            final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: now,
                                lastDate: DateTime(now.year, 12, 31));
                            if (selectedDate != null) {
                              bloc.add(
                                  ScheduleVisitChangeDateEvent(selectedDate));
                            }
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

              const Text("Agenda"),
              TextField(
                minLines: 5,
                maxLines: 10,
                maxLength: 256,
                onChanged: (value) {
                  bloc.add(ScheduleVisitChangeRemarkEvent(value));
                },
                decoration: const InputDecoration(
                    hintText: 'Type here (max 256 characters allowed)'),
              ),
              const SizedBox(height: 20),
              BlocBuilder<ScheduleVisitCallBloc, ScheduleVisitCallState>(
                builder: (context, state) {
                  return CustomMaterialButton(
                      buttonText: state is! ScheduleVisitCallLoadingState
                          ? "Save"
                          : "Loading..",
                      onPressed: () {
                        if (state is! ScheduleVisitCallLoadingState) {
                          bloc.add(ScheduleVisitSaveEvent());
                        }
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column selectStore(BuildContext context) {
    final ScheduleVisitCallBloc bloc = context.read();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Store*"),
        const SizedBox(height: 5),
        SizedBox(
          height: 35.h,
          child: AppPopup.dropDownMenu(
              options: bloc.beatPlans.map((e) => e.storeName).toList(),
              onChanged: (String? val) {
                if (val != null) {
                  bloc.add(ScheduleVisitChangeStore(val));
                }
              },
              value: context.select((ScheduleVisitCallBloc value) =>
                  value.selectedStore.storeName),
              placeholder: 'Select Store'),
        )
      ],
    );
  }
}
