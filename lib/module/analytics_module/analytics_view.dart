import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/analytics_module/analytics/analytics_bloc.dart';
import 'package:i_densfa/utility/extensions.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AnalyticsBloc(),
        child: BlocConsumer<AnalyticsBloc, AnalyticsState>(
          listener: (context, state) {},
          builder: (context, state) {
            var bloc = context.read<AnalyticsBloc>();
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
                        final date = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: now,
                            lastDate: DateTime(now.year, 12, 31));
                        if (date != null) {
                          bloc.add(AnalyticsDateChangeEvent(date));
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
                  child: ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: bloc.analyticdata.length,
                    separatorBuilder: (context, index) => Container(
                      color: Colors.grey.shade400,
                      width: 1.sw,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        color: index % 2 == 0
                            ? Colors.white
                            : Colors.grey.shade200,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(bloc.analyticdata[index].name)),
                            Expanded(
                                child: Text(
                              bloc.analyticdata[index].target,
                              textAlign: TextAlign.center,
                            )),
                            Expanded(
                                child: Text(
                              bloc.analyticdata[index].actual,
                              textAlign: TextAlign.center,
                            ))
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
