import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/my_activity_module/model/my_activity_model.dart';
import 'package:i_densfa/module/my_activity_module/my_activity_repository.dart';
import 'package:i_densfa/module/my_activity_module/myactivity/myactivity_bloc.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:month_year_picker/month_year_picker.dart';

class MyActivityView extends StatelessWidget {
  const MyActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "My Activity",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: RepositoryProvider(
        create: (context) => MyActivityRepository(),
        child: BlocProvider(
          create: (context) =>
              MyActivityBloc(context.read())..add(GetActivityEvent()),
          child: BlocConsumer<MyActivityBloc, MyActivityState>(
            listenWhen: (previous, current) => current is MyActivityShowSnack,
            listener: (context, state) {
              if (state is MyActivityShowSnack) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                ));
              }
            },
            buildWhen: (previous, current) => current is! MyActivityShowSnack,
            builder: (context, state) {
              if (state is MyAcivityLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }
              final bloc = context.read<MyActivityBloc>();
              return Column(
                children: [
                  Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 1.0, // soften the shadow
                            spreadRadius: 1.0, //extend the shadow
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context
                                .read<MyActivityBloc>()
                                .selected
                                .toStringFormat("MMMM yyyy"),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                final now = DateTime.now();
                                final date = await showMonthYearPicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: DateTime(now.year),
                                  lastDate: DateTime(now.year + 1),
                                );
                                if (date != null && context.mounted) {
                                  context
                                      .read<MyActivityBloc>()
                                      .add(MyActivityChangeMonth(date));
                                }
                              },
                              icon: const Icon(
                                Icons.calendar_month,
                                color: Colors.amber,
                              )),
                        ],
                      )),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                            child: Center(
                          child: Text(
                            "Days",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        )),
                        // Expanded(
                        //     child: Center(
                        //   child: Text(
                        //     "First",
                        //     style: TextStyle(
                        //       fontSize: 12.sp,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.red,
                        //     ),
                        //   ),
                        // )),
                        // Expanded(
                        //     child: Center(
                        //   child: Text(
                        //     "Last",
                        //     style: TextStyle(
                        //       fontSize: 12.sp,
                        //       fontWeight: FontWeight.bold,
                        //       color: Theme.of(context).primaryColor,
                        //     ),
                        //   ),
                        // )),
                        Expanded(
                            child: Center(
                          child: Text(
                            "In",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        )),
                        Expanded(
                            child: Center(
                          child: Text(
                            "0ut",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        )),
                        Expanded(
                            child: Center(
                          child: FittedBox(
                            child: Text(
                              "Span(Hrs)",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(color: Colors.grey[300]!, height: 1),
                  bloc.attandenceData.isEmpty
                      ? Center(
                          child: TextButton(
                            child: const Text("Retry"),
                            onPressed: () => bloc.add(GetActivityEvent()),
                          ),
                        )
                      : Expanded(
                          child: ListView.separated(
                              itemCount: bloc.attandenceData.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              separatorBuilder: (context, index) => Container(
                                  color: Colors.grey[300]!, height: 1),
                              itemBuilder: (context, index) => SingleActivity(
                                  index, bloc.attandenceData[index])),
                        )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SingleActivity extends StatelessWidget {
  final int index;
  final AttendanceData attandenceData;

  const SingleActivity(this.index, this.attandenceData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
              child: Center(
            child: Text(
              attandenceData.date.toStringFormat("dd MMM"),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
                color: Colors.black,
              ),
            ),
          )),
          // Expanded(
          //     child: Center(
          //   child: Text(
          //     "0${index + 1} : 0${index + 5}:41",
          //     style: TextStyle(
          //       fontSize: 10.sp,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.black,
          //     ),
          //   ),
          // )),
          // Expanded(
          //     child: Center(
          //   child: Text(
          //     "0${index + 8} : 0${index + 5}:41",
          //     style: TextStyle(
          //       fontSize: 10.sp,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.black,
          //     ),
          //   ),
          // )),
          Expanded(
              child: Center(
            child: Text(
              attandenceData.inTime,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              attandenceData.outTime,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              attandenceData.timeSpan,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          )),
        ],
      ),
    );
  }
}
