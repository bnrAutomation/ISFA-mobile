import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/analytics_module/analytics/analytics_bloc.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/extensions.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xff959595), Color(0xff636363)])),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Align(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        borderedBox(
                          child: const SizedBox(
                            width: 80,
                            height: 80,
                            child: ColoredBox(color: Colors.red),
                          ),
                        ),
                        Text('Abhay Gupta',
                            style: textTheme.bodyLarge
                                ?.copyWith(color: Colors.white)),
                        Text('TSI| Self & Team',
                            style: textTheme.bodySmall
                                ?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {},
                      color: Colors.white,
                      iconSize: 30,
                      icon: const Icon(Icons.replay_circle_filled_rounded),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              height: 70,
              child: CustomMaterialButton(
                buttonText: "Change Date",
                onPressed: () {
                  final selectedDate = showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  debugPrint(selectedDate.toString());
                },
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffffcd38)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xffffcd38),
                        blurRadius: 1,
                        spreadRadius: 0.5,
                      )
                    ]),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Coverage",
                          style: textTheme.titleLarge,
                        ),
                        Text(
                          "Target",
                          style: textTheme.titleSmall,
                        ),
                        Text(
                          "1,00,000",
                          style: textTheme.titleMedium,
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
                    const Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: 75.5 / 100,
                            backgroundColor: Color(0xffededee),
                            strokeWidth: 12,
                            color: Color(0xffffcd38),
                          ),
                        ),
                        Text("75.5%")
                      ],
                    )
                  ],
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
        border: Border.all(color: const Color(0xffffcd38)),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
    );
  }

  Widget shadowBox({required Widget child}) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xffffcd38), blurRadius: 2, spreadRadius: 2)
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
