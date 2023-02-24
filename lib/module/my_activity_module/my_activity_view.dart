import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/my_activity_module/myactivity/myactivity_bloc.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:intl/intl.dart';

class MyActivityView extends StatelessWidget {
  const MyActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyActivityBloc(),
      child: BlocBuilder<MyActivityBloc, MyActivityState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              backgroundColor: const Color(0XFF003D5B),
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                "My Activity",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
            body: Column(
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
                          DateFormat().addPattern("MMMM yyyy").format(
                              BlocProvider.of<MyActivityBloc>(context)
                                      .selected ??
                                  DateTime.now()),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        IconButton(
                            onPressed: () async => {
                                  BlocProvider.of<MyActivityBloc>(context).add(
                                      MyActivityChangeMonth(
                                          await showMonthYearPicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate:
                                                  DateTime(DateTime.now().year),
                                              lastDate: DateTime(
                                                  DateTime.now().year + 1))))
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
                      Expanded(
                          child: Center(
                        child: Text(
                          "First",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      )),
                      Expanded(
                          child: Center(
                        child: Text(
                          "Last",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0XFF003D5B),
                          ),
                        ),
                      )),
                      Expanded(
                          child: Center(
                        child: Text(
                          "Span(Hrs)",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      )),
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
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(color: Colors.grey[300]!, height: 1),
                Expanded(
                  child: ListView.separated(
                      itemCount: 5,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) =>
                          Container(color: Colors.grey[300]!, height: 1),
                      itemBuilder: (context, index) => SingleActivity(index)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SingleActivity extends StatelessWidget {
  final int index;

  const SingleActivity(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyActivityBloc, MyActivityState>(
      bloc: MyActivityBloc(),
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                  child: Center(
                child: Text(
                  "${index + 1} ${DateFormat().addPattern("MMM").format(BlocProvider.of<MyActivityBloc>(context).selected ?? DateTime.now())}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                    color: Colors.black,
                  ),
                ),
              )),
              Expanded(
                  child: Center(
                child: Text(
                  "0${index + 1} : 0${index + 5}:41",
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
                  "0${index + 8} : 0${index + 5}:41",
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
                  "${index + 1} Hrs",
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
                  "${index + 2} : 0${index + 5}:41",
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
                  "${index + 7} : 0${index + 5}:41",
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
      },
    );
  }
}
