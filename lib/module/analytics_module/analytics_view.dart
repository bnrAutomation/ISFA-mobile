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
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.grey,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.replay_circle_filled_outlined),
                )
              ],
              title: const Text('Analytics'),
              leading: const Icon(Icons.keyboard_backspace),
              centerTitle: true,
              flexibleSpace: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 50),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Icon(Icons.analytics),
                  ),
                  borderedBox(
                    child: const SizedBox(
                      width: 80,
                      height: 80,
                      child: ColoredBox(color: Colors.red),
                    ),
                  ),
                  const Text('Abhay Gupta'),
                  const Text('TSI| Self & Team'),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
              child: shadowBox(
                child: borderedBox(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    width: 1.sw,
                    decoration: const BoxDecoration(color: Colors.white),
                    alignment: Alignment.center,
                    child: Text(
                      "Change Date",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: borderedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Coverage",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "Target",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              "1,00,000",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "Target",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              "1,00,000",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: 75.5 / 100,
                                backgroundColor: Colors.brown.shade50,
                                strokeWidth: 12,
                                color: Colors.yellow,
                              ),
                            ),
                            const Text("75.5%")
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget borderedBox({required Widget child}) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.yellow)),
        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child));
  }

  Widget shadowBox({required Widget child}) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.yellow, blurRadius: 2, spreadRadius: 2)
            ]),
        child: child);
  }
}

class Analytics1View extends StatelessWidget {
  const Analytics1View({super.key});

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
